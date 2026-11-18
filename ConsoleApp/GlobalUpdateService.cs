using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MySqlConnector;
using StackExchange.Redis;

namespace ConsoleApp
{
    /// <summary>
    /// Implements global UPDATE operations spanning M1 (MySQL) and M2 (Redis)
    /// across the proper horizontal fragment (Kaunas or Vilnius) using application-level
    /// Saga coordination: Idempotency Key (TTL), M1 ACID update, M2 Retry, and M1 Compensation.
    /// </summary>
    public sealed class GlobalUpdateService
    {
        private readonly ShardRouter _router;
        private static readonly TimeSpan IdempotencyTtl = TimeSpan.FromMinutes(10);

        public sealed record RestaurantDetails(
            int RestoranasId,
            string Pavadinimas,
            string Vietove,
            string? Telefonas,
            string? Svetaine);

        public sealed record EmployeeDetails(
            int DarbuotojasId,
            string Vardas,
            string Pavarde,
            string Pareiga,
            bool Atostogauja,
            string Telefonas,
            string ElPastas,
            int RestoranasId);

        public GlobalUpdateService(ShardRouter router)
        {
            _router = router;
        }

        /// <summary>
        /// Fetches current restaurant details from M1 for the specified city fragment.
        /// </summary>
        public async Task<RestaurantDetails?> GetRestaurantAsync(CityFragment city, int restoranasId)
        {
            if (restoranasId <= 0)
                throw new ArgumentException("Restorano ID turi būti > 0.", nameof(restoranasId));

            var target = _router.GetTarget(city);
            await using var conn = new MySqlConnection(target.MySqlConnString);
            await conn.OpenAsync();
            const string sql = @"
                SELECT restoranas_id, pavadinimas, vietove, telefonas, svetaine
                FROM restoranas
                WHERE restoranas_id = @id;";
            await using var cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@id", restoranasId);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                return null;

            return new RestaurantDetails(
                reader.GetInt32("restoranas_id"),
                reader.GetString("pavadinimas"),
                reader.GetString("vietove"),
                reader.IsDBNull(reader.GetOrdinal("telefonas")) ? null : reader.GetString("telefonas"),
                reader.IsDBNull(reader.GetOrdinal("svetaine")) ? null : reader.GetString("svetaine"));
        }

        /// <summary>
        /// UPDATE: Edits an existing restaurant in both M1 (MySQL restoranas) and M2 (Redis restoranas:{id})
        /// within the specified city fragment (Kaunas or Vilnius only).
        /// Coordination: Idempotency TTL -> M1 snapshot + ACID UPDATE -> M2 MULTI/EXEC with Retry -> M1 Compensation on failure.
        /// </summary>
        public async Task<bool> UpdateRestaurantAsync(
            CityFragment city,
            int restoranasId,
            string name,
            string? phone,
            string? website,
            string? idempotencyKey = null,
            bool simulateM2Failure = false)
        {
            if (restoranasId <= 0)
                throw new ArgumentException("Restorano ID turi būti > 0.", nameof(restoranasId));
            if (string.IsNullOrWhiteSpace(name))
                throw new ArgumentException("Restorano pavadinimas negali būti tuščias.", nameof(name));

            var target = _router.GetTarget(city);
            string cityStr = city.ToString();
            string trimmedName = name.Trim();
            string? trimmedPhone = string.IsNullOrWhiteSpace(phone) ? null : phone.Trim();
            string? trimmedWebsite = string.IsNullOrWhiteSpace(website) ? null : website.Trim();

            string txKey = $"tx:idemp:rest-upd:{cityStr}:{idempotencyKey ?? Guid.NewGuid().ToString("N")}";

            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL UPDATE (Restoranas) -> Fragmentas: {cityStr}, restoranas_id={restoranasId} ===");

            // 0. Idempotency check with Redis TTL
            bool acquired = await target.RedisDb.StringSetAsync(txKey, "IN_PROGRESS", IdempotencyTtl, When.NotExists);
            if (!acquired)
            {
                var existing = await target.RedisDb.StringGetAsync(txKey);
                Console.WriteLine($"[Idempotency] Operacija su raktu '{txKey}' jau užregistruota (būsena: {existing}). Pakartotinis atnaujinimas sustabdytas.");
                return false;
            }

            // 1. Read previous state & apply M1 MySQL local ACID update
            RestaurantDetails? previous;
            try
            {
                await using var conn = new MySqlConnection(target.MySqlConnString);
                await conn.OpenAsync();
                await using var tx = await conn.BeginTransactionAsync();

                const string selectSql = @"
                    SELECT restoranas_id, pavadinimas, vietove, telefonas, svetaine
                    FROM restoranas
                    WHERE restoranas_id = @id
                    FOR UPDATE;";
                await using (var selectCmd = new MySqlCommand(selectSql, conn, tx))
                {
                    selectCmd.Parameters.AddWithValue("@id", restoranasId);
                    await using var reader = await selectCmd.ExecuteReaderAsync();
                    if (!await reader.ReadAsync())
                    {
                        await tx.RollbackAsync();
                        await target.RedisDb.KeyDeleteAsync(txKey);
                        Console.WriteLine($"Restoranas ({cityStr}, restoranas_id={restoranasId}) nerastas {target.MySqlDatabaseName}.");
                        return false;
                    }

                    previous = new RestaurantDetails(
                        reader.GetInt32("restoranas_id"),
                        reader.GetString("pavadinimas"),
                        reader.GetString("vietove"),
                        reader.IsDBNull(reader.GetOrdinal("telefonas")) ? null : reader.GetString("telefonas"),
                        reader.IsDBNull(reader.GetOrdinal("svetaine")) ? null : reader.GetString("svetaine"));
                }

                const string updateSql = @"
                    UPDATE restoranas
                    SET pavadinimas = @pav,
                        telefonas = @tel,
                        svetaine = @svet
                    WHERE restoranas_id = @id;";
                await using (var updateCmd = new MySqlCommand(updateSql, conn, tx))
                {
                    updateCmd.Parameters.AddWithValue("@id", restoranasId);
                    updateCmd.Parameters.AddWithValue("@pav", trimmedName);
                    updateCmd.Parameters.AddWithValue("@tel", (object?)trimmedPhone ?? DBNull.Value);
                    updateCmd.Parameters.AddWithValue("@svet", (object?)trimmedWebsite ?? DBNull.Value);
                    await updateCmd.ExecuteNonQueryAsync();
                }

                await tx.CommitAsync();
                Console.WriteLine($"[1/2] M1 ({target.MySqlDatabaseName}): atnaujintas restoranas_id={restoranasId} (ACID COMMIT).");
            }
            catch (Exception ex)
            {
                await target.RedisDb.KeyDeleteAsync(txKey);
                Console.WriteLine($"[KLAIDA M1] Nepavyko atnaujinti MySQL: {ex.Message}");
                return false;
            }

            // 2. Step 2 (M2 Redis transaction with Retry)
            const int maxAttempts = 3;
            Exception? lastM2Error = null;
            string redisKey = $"restoranas:{restoranasId}";
            for (int attempt = 1; attempt <= maxAttempts; attempt++)
            {
                try
                {
                    if (simulateM2Failure)
                        throw new InvalidOperationException("Imituotas M2 (Redis) mazgo gedimas demonstracijai.");

                    var redisTx = target.RedisDb.CreateTransaction();
                    var entries = new List<HashEntry>
                    {
                        new("pavadinimas", trimmedName)
                    };
                    if (trimmedPhone is not null)
                        entries.Add(new("telefonas", trimmedPhone));
                    if (trimmedWebsite is not null)
                        entries.Add(new("svetaine", trimmedWebsite));

                    _ = redisTx.HashSetAsync(redisKey, entries.ToArray());
                    if (trimmedPhone is null)
                        _ = redisTx.HashDeleteAsync(redisKey, "telefonas");
                    if (trimmedWebsite is null)
                        _ = redisTx.HashDeleteAsync(redisKey, "svetaine");

                    bool committed = await redisTx.ExecuteAsync();
                    if (!committed)
                        throw new InvalidOperationException("Redis MULTI/EXEC neįvyko.");

                    await target.RedisDb.StringSetAsync(txKey, $"COMPLETED:{restoranasId}", IdempotencyTtl);
                    Console.WriteLine($"[2/2] M2 ({target.RedisEndpoint}): atnaujintas {redisKey} (bandymas {attempt}/{maxAttempts}).");
                    return true;
                }
                catch (Exception ex)
                {
                    lastM2Error = ex;
                    Console.WriteLine($"[Įspėjimas M2] Bandymas {attempt}/{maxAttempts} nepavyko: {ex.Message}");
                    if (attempt < maxAttempts)
                        await Task.Delay(150 * attempt);
                }
            }

            // 3. Saga Compensation: restore M1 previous values because M2 failed after retries
            Console.WriteLine($"[KOMPENSACIJA] M2 nepavyko ({lastM2Error?.Message}). Atstatomas restoranas_id={restoranasId} į pradinę būseną M1 ({target.MySqlDatabaseName})...");
            try
            {
                await using var conn = new MySqlConnection(target.MySqlConnString);
                await conn.OpenAsync();
                const string restoreSql = @"
                    UPDATE restoranas
                    SET pavadinimas = @pav,
                        telefonas = @tel,
                        svetaine = @svet
                    WHERE restoranas_id = @id;";
                await using var cmd = new MySqlCommand(restoreSql, conn);
                cmd.Parameters.AddWithValue("@id", restoranasId);
                cmd.Parameters.AddWithValue("@pav", previous.Pavadinimas);
                cmd.Parameters.AddWithValue("@tel", (object?)previous.Telefonas ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@svet", (object?)previous.Svetaine ?? DBNull.Value);
                int restored = await cmd.ExecuteNonQueryAsync();
                await target.RedisDb.KeyDeleteAsync(txKey);
                Console.WriteLine($"[KOMPENSACIJA SĖKMINGA] Atstatyta eilučių M1: {restored}. Globalus nuoseklumas išlaikytas.");
            }
            catch (Exception compEx)
            {
                Console.WriteLine($"[KRITINĖ KLAIDA] Kompensacija nepavyko: {compEx.Message}. Reikia rankinio patikrinimo raktui {txKey}.");
            }

            return false;
        }

        /// <summary>
        /// Fetches current employee details from M1 for the specified city fragment.
        /// </summary>
        public async Task<EmployeeDetails?> GetEmployeeAsync(CityFragment city, int darbuotojasId)
        {
            if (darbuotojasId <= 0)
                throw new ArgumentException("Darbuotojo ID turi būti > 0.", nameof(darbuotojasId));

            var target = _router.GetTarget(city);
            await using var conn = new MySqlConnection(target.MySqlConnString);
            await conn.OpenAsync();
            const string sql = @"
                SELECT darbuotojas_id, vardas, pavarde, pareiga, atostogauja, telefonas, el_pastas, restoranas_id
                FROM darbuotojas
                WHERE darbuotojas_id = @id;";
            await using var cmd = new MySqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@id", darbuotojasId);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                return null;

            return new EmployeeDetails(
                reader.GetInt32("darbuotojas_id"),
                reader.GetString("vardas"),
                reader.GetString("pavarde"),
                reader.GetString("pareiga"),
                reader.GetBoolean("atostogauja"),
                reader.GetString("telefonas"),
                reader.GetString("el_pastas"),
                reader.GetInt32("restoranas_id"));
        }

        /// <summary>
        /// UPDATE: Edits an existing darbuotojas in M1.
        /// If targetCity differs from sourceCity (FK restoranas_id moved between Kaunas and Vilnius),
        /// migrates the employee across horizontal M1 databases using Saga coordination
        /// (Idempotency TTL -> INSERT in destination shard -> DELETE in source shard -> Compensation on failure).
        /// </summary>
        public async Task<int?> UpdateEmployeeAsync(
            CityFragment sourceCity,
            int darbuotojasId,
            string vardas,
            string pavarde,
            string pareiga,
            bool atostogauja,
            string telefonas,
            string elPastas,
            CityFragment targetCity,
            int targetRestoranasId,
            string? idempotencyKey = null,
            bool simulateSourceDeleteFailure = false)
        {
            if (darbuotojasId <= 0)
                throw new ArgumentException("Darbuotojo ID turi būti > 0.", nameof(darbuotojasId));
            if (targetRestoranasId <= 0)
                throw new ArgumentException("Restorano ID turi būti > 0.", nameof(targetRestoranasId));
            if (string.IsNullOrWhiteSpace(vardas) ||
                string.IsNullOrWhiteSpace(pavarde) ||
                string.IsNullOrWhiteSpace(pareiga) ||
                string.IsNullOrWhiteSpace(telefonas) ||
                string.IsNullOrWhiteSpace(elPastas))
            {
                throw new ArgumentException("Visi privalomi darbuotojo laukai (vardas, pavardė, pareiga, telefonas, el. paštas) turi būti užpildyti.");
            }

            if (!await _router.RestaurantExistsInCityAsync(targetCity, targetRestoranasId))
            {
                Console.WriteLine($"Klaida: restoranas su restoranas_id={targetRestoranasId} neegzistuoja {targetCity} fragmente.");
                return null;
            }

            string trimmedVardas = vardas.Trim();
            string trimmedPavarde = pavarde.Trim();
            string trimmedPareiga = pareiga.Trim();
            string trimmedTel = telefonas.Trim();
            string trimmedEmail = elPastas.Trim();

            var sourceTarget = _router.GetTarget(sourceCity);

            // Same-shard update: simple local ACID UPDATE in M1
            if (sourceCity == targetCity)
            {
                Console.WriteLine();
                Console.WriteLine($"=== UPDATE (Darbuotojas) -> Fragmentas: {sourceCity}, darbuotojas_id={darbuotojasId} ===");

                await using var conn = new MySqlConnection(sourceTarget.MySqlConnString);
                await conn.OpenAsync();
                await using var tx = await conn.BeginTransactionAsync();

                const string sql = @"
                    UPDATE darbuotojas
                    SET vardas = @vardas,
                        pavarde = @pavarde,
                        pareiga = @pareiga,
                        atostogauja = @atostogauja,
                        telefonas = @telefonas,
                        el_pastas = @elPastas,
                        restoranas_id = @restId
                    WHERE darbuotojas_id = @id;";
                await using var cmd = new MySqlCommand(sql, conn, tx);
                cmd.Parameters.AddWithValue("@id", darbuotojasId);
                cmd.Parameters.AddWithValue("@vardas", trimmedVardas);
                cmd.Parameters.AddWithValue("@pavarde", trimmedPavarde);
                cmd.Parameters.AddWithValue("@pareiga", trimmedPareiga);
                cmd.Parameters.AddWithValue("@atostogauja", atostogauja ? 1 : 0);
                cmd.Parameters.AddWithValue("@telefonas", trimmedTel);
                cmd.Parameters.AddWithValue("@elPastas", trimmedEmail);
                cmd.Parameters.AddWithValue("@restId", targetRestoranasId);

                int affected = await cmd.ExecuteNonQueryAsync();
                if (affected == 0)
                {
                    await tx.RollbackAsync();
                    Console.WriteLine($"Darbuotojas ({sourceCity}, darbuotojas_id={darbuotojasId}) nerastas {sourceTarget.MySqlDatabaseName}.");
                    return null;
                }

                await tx.CommitAsync();
                Console.WriteLine($"[1/1] M1 ({sourceTarget.MySqlDatabaseName}): atnaujintas darbuotojas_id={darbuotojasId} (ACID COMMIT).");
                return darbuotojasId;
            }

            // Cross-shard move (Kaunas <-> Vilnius) using Saga coordination
            var destTarget = _router.GetTarget(targetCity);
            string txKey = $"tx:idemp:emp-move:{sourceCity}:{targetCity}:{idempotencyKey ?? Guid.NewGuid().ToString("N")}";

            Console.WriteLine();
            Console.WriteLine($"=== CROSS-SHARD MOVE (Darbuotojas) -> {sourceCity} ({sourceTarget.MySqlDatabaseName}) => {targetCity} ({destTarget.MySqlDatabaseName}) ===");

            bool acquired = await sourceTarget.RedisDb.StringSetAsync(txKey, "IN_PROGRESS", IdempotencyTtl, When.NotExists);
            if (!acquired)
            {
                var existing = await sourceTarget.RedisDb.StringGetAsync(txKey);
                Console.WriteLine($"[Idempotency] Operacija su raktu '{txKey}' jau užregistruota (būsena: {existing}). Pakartotinis perkėlimas sustabdytas.");
                return null;
            }

            // Verify employee exists in source shard
            var existingEmp = await GetEmployeeAsync(sourceCity, darbuotojasId);
            if (existingEmp is null)
            {
                await sourceTarget.RedisDb.KeyDeleteAsync(txKey);
                Console.WriteLine($"Darbuotojas ({sourceCity}, darbuotojas_id={darbuotojasId}) nerastas {sourceTarget.MySqlDatabaseName}.");
                return null;
            }

            // Always allocate a new city-scoped darbuotojas_id at the end of the destination shard
            int destEmployeeId = await _router.GetNextCityMySqlIdAsync(targetCity, "darbuotojas", "darbuotojas_id");
            Console.WriteLine($"[ID] Paskirtas naujas {targetCity} fragmento darbuotojas_id={destEmployeeId}.");

            // Step 1: Insert into destination M1 shard
            try
            {
                await using var destConn = new MySqlConnection(destTarget.MySqlConnString);
                await destConn.OpenAsync();
                await using var destTx = await destConn.BeginTransactionAsync();

                const string insertSql = @"
                    INSERT INTO darbuotojas (darbuotojas_id, vardas, pavarde, pareiga, atostogauja, telefonas, el_pastas, restoranas_id)
                    VALUES (@id, @vardas, @pavarde, @pareiga, @atostogauja, @telefonas, @elPastas, @restId);";
                await using var insertCmd = new MySqlCommand(insertSql, destConn, destTx);
                insertCmd.Parameters.AddWithValue("@id", destEmployeeId);
                insertCmd.Parameters.AddWithValue("@vardas", trimmedVardas);
                insertCmd.Parameters.AddWithValue("@pavarde", trimmedPavarde);
                insertCmd.Parameters.AddWithValue("@pareiga", trimmedPareiga);
                insertCmd.Parameters.AddWithValue("@atostogauja", atostogauja ? 1 : 0);
                insertCmd.Parameters.AddWithValue("@telefonas", trimmedTel);
                insertCmd.Parameters.AddWithValue("@elPastas", trimmedEmail);
                insertCmd.Parameters.AddWithValue("@restId", targetRestoranasId);
                await insertCmd.ExecuteNonQueryAsync();
                await destTx.CommitAsync();

                Console.WriteLine($"[1/2] M1 ({destTarget.MySqlDatabaseName}): įterptas darbuotojas_id={destEmployeeId} (restoranas_id={targetRestoranasId}).");
            }
            catch (Exception ex)
            {
                await sourceTarget.RedisDb.KeyDeleteAsync(txKey);
                Console.WriteLine($"[KLAIDA M1 paskirties fragmente] Nepavyko įterpti į {destTarget.MySqlDatabaseName}: {ex.Message}");
                return null;
            }

            // Step 2: Delete from source M1 shard
            try
            {
                if (simulateSourceDeleteFailure)
                    throw new InvalidOperationException("Imituotas pradinio M1 mazgo gedimas demonstracijai.");

                await using var srcConn = new MySqlConnection(sourceTarget.MySqlConnString);
                await srcConn.OpenAsync();
                await using var srcTx = await srcConn.BeginTransactionAsync();

                await using var deleteCmd = new MySqlCommand("DELETE FROM darbuotojas WHERE darbuotojas_id = @id;", srcConn, srcTx);
                deleteCmd.Parameters.AddWithValue("@id", darbuotojasId);
                await deleteCmd.ExecuteNonQueryAsync();
                await srcTx.CommitAsync();

                await sourceTarget.RedisDb.StringSetAsync(txKey, $"COMPLETED:{destEmployeeId}", IdempotencyTtl);
                Console.WriteLine($"[2/2] M1 ({sourceTarget.MySqlDatabaseName}): pašalintas darbuotojas_id={darbuotojasId}. Perkėlimas į {targetCity} baigtas.");
                return destEmployeeId;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[KOMPENSACIJA] Nepavyko pašalinti iš {sourceTarget.MySqlDatabaseName} ({ex.Message}). Šalinamas darbuotojas_id={destEmployeeId} iš {destTarget.MySqlDatabaseName}...");
                try
                {
                    await using var destConn = new MySqlConnection(destTarget.MySqlConnString);
                    await destConn.OpenAsync();
                    await using var compCmd = new MySqlCommand("DELETE FROM darbuotojas WHERE darbuotojas_id = @id;", destConn);
                    compCmd.Parameters.AddWithValue("@id", destEmployeeId);
                    int deleted = await compCmd.ExecuteNonQueryAsync();
                    await sourceTarget.RedisDb.KeyDeleteAsync(txKey);
                    Console.WriteLine($"[KOMPENSACIJA SĖKMINGA] Pašalinta eilučių {destTarget.MySqlDatabaseName}: {deleted}.");
                }
                catch (Exception compEx)
                {
                    Console.WriteLine($"[KRITINĖ KLAIDA] Kompensacija nepavyko: {compEx.Message}. Reikia rankinio patikrinimo raktui {txKey}.");
                }
                return null;
            }
        }
    }
}
