using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using MySqlConnector;
using StackExchange.Redis;

namespace ConsoleApp
{
    /// <summary>
    /// Implements global INSERT operations spanning M1 (MySQL) and M2 (Redis)
    /// across the proper horizontal fragment (Kaunas or Vilnius) using application-level
    /// Saga coordination: Idempotency Key (TTL), Retry, Server-side Lua atomicity, and Compensation.
    /// </summary>
    public sealed class GlobalInsertService
    {
        private readonly ShardRouter _router;
        private static readonly TimeSpan IdempotencyTtl = TimeSpan.FromMinutes(10);

        // Atomic Lua script: verifies stock >= needed for all products, then deducts them together.
        // KEYS: produktas:{id} hashes
        // ARGV: required quantities (matching KEYS order)
        private const string LuaCheckAndDeductStock = @"
for i = 1, #KEYS do
    local exists = redis.call('EXISTS', KEYS[i])
    if exists == 0 then
        return {0, 'MISSING', KEYS[i]}
    end
    local cur = tonumber(redis.call('HGET', KEYS[i], 'kiekis') or '0')
    local req = tonumber(ARGV[i])
    if cur < req then
        return {0, 'INSUFFICIENT', KEYS[i], tostring(cur), tostring(req)}
    end
end
for i = 1, #KEYS do
    local req = tonumber(ARGV[i])
    local newVal = redis.call('HINCRBYFLOAT', KEYS[i], 'kiekis', -req)
end
return {1, 'OK'}
";

        // Compensating Lua script: restores deducted quantities if downstream MySQL step fails.
        private const string LuaRestoreStock = @"
for i = 1, #KEYS do
    local addQty = tonumber(ARGV[i])
    redis.call('HINCRBYFLOAT', KEYS[i], 'kiekis', addQty)
end
return 1
";

        public GlobalInsertService(ShardRouter router)
        {
            _router = router;
        }

        /// <summary>
        /// INSERT 1: Creates a new restaurant in M1 (restoranas) and M2 (restoranas:{id} + initial inventorius:{invId})
        /// sharing the same city-scoped (vertically unique) restoranas_id and routed by city (Kaunas vs Vilnius).
        /// Coordination: Idempotency TTL -> M1 MySQL local ACID -> M2 Redis batch with Retry -> M1 Compensation on failure.
        /// </summary>
        public async Task<int?> InsertRestaurantWithInventoryAsync(
            string name,
            CityFragment city,
            string? phone,
            string? website,
            string initialInventoryName,
            int initialInventoryQty,
            string? idempotencyKey = null,
            bool simulateM2Failure = false)
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new ArgumentException("Restorano pavadinimas negali būti tuščias.", nameof(name));
            if (string.IsNullOrWhiteSpace(initialInventoryName) || initialInventoryQty <= 0)
                throw new ArgumentException("Neteisingi pradinio inventoriaus duomenys.");

            var target = _router.GetTarget(city);
            string cityStr = city.ToString();
            string txKey = $"tx:idemp:rest:{cityStr}:{idempotencyKey ?? Guid.NewGuid().ToString("N")}";

            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL INSERT (Restoranas + Inventorius) -> Fragmentas: {cityStr} ===");

            // 0. Idempotency check with Redis TTL (Redis-specific feature)
            bool acquired = await target.RedisDb.StringSetAsync(txKey, "IN_PROGRESS", IdempotencyTtl, When.NotExists);
            if (!acquired)
            {
                var existing = await target.RedisDb.StringGetAsync(txKey);
                Console.WriteLine($"[Idempotency] Operacija su raktu '{txKey}' jau užregistruota (būsena: {existing}). Pakartotinis įterpimas sustabdytas.");
                return null;
            }

            // 1. Allocate city-scoped IDs (vertically unique across M1 & M2 within this city; may overlap across cities)
            int newRestId = await _router.GetNextCityRestaurantIdAsync(city);
            int newInvId = await _router.GetNextCityRedisIdAsync(city, RedisIndexService.IdxInventorius, "inventorius_id");
            Console.WriteLine($"[1/3] Sugeneruotas {cityStr} fragmento ID (vertikaliai unikalus M1+M2): restoranas_id={newRestId}, inventorius_id={newInvId}");

            // 2. Step 1 (M1 MySQL local ACID transaction)
            try
            {
                await using var conn = new MySqlConnection(target.MySqlConnString);
                await conn.OpenAsync();
                await using var tx = await conn.BeginTransactionAsync();

                const string sql = @"
                    INSERT INTO restoranas (restoranas_id, pavadinimas, vietove, telefonas, svetaine)
                    VALUES (@id, @pav, @viet, @tel, @svet);";
                await using var cmd = new MySqlCommand(sql, conn, tx);
                cmd.Parameters.AddWithValue("@id", newRestId);
                cmd.Parameters.AddWithValue("@pav", name.Trim());
                cmd.Parameters.AddWithValue("@viet", cityStr);
                cmd.Parameters.AddWithValue("@tel", string.IsNullOrWhiteSpace(phone) ? DBNull.Value : phone.Trim());
                cmd.Parameters.AddWithValue("@svet", string.IsNullOrWhiteSpace(website) ? DBNull.Value : website.Trim());
                await cmd.ExecuteNonQueryAsync();
                await tx.CommitAsync();

                Console.WriteLine($"[2/3] M1 ({target.MySqlDatabaseName}): įterptas restoranas_id={newRestId} (ACID COMMIT).");
            }
            catch (Exception ex)
            {
                await target.RedisDb.KeyDeleteAsync(txKey);
                Console.WriteLine($"[KLAIDA M1] Nepavyko įterpti į MySQL: {ex.Message}");
                return null;
            }

            // 3. Step 2 (M2 Redis transaction with Retry)
            const int maxAttempts = 3;
            Exception? lastM2Error = null;
            for (int attempt = 1; attempt <= maxAttempts; attempt++)
            {
                try
                {
                    if (simulateM2Failure)
                        throw new InvalidOperationException("Imituotas M2 (Redis) mazgo gedimas demonstracijai.");

                    var redisTx = target.RedisDb.CreateTransaction();

                    var restEntries = new List<HashEntry>
                    {
                        new("restoranas_id", newRestId),
                        new("pavadinimas", name.Trim()),
                        new("vietove", cityStr)
                    };
                    if (!string.IsNullOrWhiteSpace(phone))
                        restEntries.Add(new("telefonas", phone.Trim()));
                    if (!string.IsNullOrWhiteSpace(website))
                        restEntries.Add(new("svetaine", website.Trim()));

                    _ = redisTx.HashSetAsync($"restoranas:{newRestId}", restEntries.ToArray());
                    _ = redisTx.HashSetAsync($"inventorius:{newInvId}", new HashEntry[]
                    {
                        new("inventorius_id", newInvId),
                        new("pavadinimas", initialInventoryName.Trim()),
                        new("kiekis", initialInventoryQty),
                        new("restoranas_id", newRestId)
                    });

                    bool committed = await redisTx.ExecuteAsync();
                    if (!committed)
                        throw new InvalidOperationException("Redis MULTI/EXEC neįvyko.");

                    await target.RedisDb.StringSetAsync(txKey, $"COMPLETED:{newRestId}", IdempotencyTtl);
                    Console.WriteLine($"[3/3] M2 ({target.RedisEndpoint}): įrašyta restoranas:{newRestId} ir inventorius:{newInvId} (bandymas {attempt}/{maxAttempts}).");
                    return newRestId;
                }
                catch (Exception ex)
                {
                    lastM2Error = ex;
                    Console.WriteLine($"[Įspėjimas M2] Bandymas {attempt}/{maxAttempts} nepavyko: {ex.Message}");
                    if (attempt < maxAttempts)
                        await Task.Delay(150 * attempt);
                }
            }

            // 4. Saga Compensation: rollback M1 because M2 failed after retries
            Console.WriteLine($"[KOMPENSACIJA] M2 nepavyko ({lastM2Error?.Message}). Šalinamas restoranas_id={newRestId} iš M1 ({target.MySqlDatabaseName})...");
            try
            {
                await using var conn = new MySqlConnection(target.MySqlConnString);
                await conn.OpenAsync();
                await using var cmd = new MySqlCommand("DELETE FROM restoranas WHERE restoranas_id = @id;", conn);
                cmd.Parameters.AddWithValue("@id", newRestId);
                int deleted = await cmd.ExecuteNonQueryAsync();
                await target.RedisDb.KeyDeleteAsync(txKey);
                Console.WriteLine($"[KOMPENSACIJA SĖKMINGA] Pašalinta eilučių M1: {deleted}. Globalus nuoseklumas išlaikytas.");
            }
            catch (Exception compEx)
            {
                Console.WriteLine($"[KRITINĖ KLAIDA] Kompensacija nepavyko: {compEx.Message}. Reikia rankinio patikrinimo raktui {txKey}.");
            }
            return null;
        }

        /// <summary>
        /// INSERT 2: Creates a new customer order (kliento_uzsakymas + kliento_eilute) in M1 (MySQL)
        /// and atomically deducts required recipe product stock in M2 (Redis) using a server-side Lua script.
        /// If M1 fails, executes a compensating Lua script in M2 to restore stock.
        /// </summary>
        public async Task<int?> InsertCustomerOrderWithStockDeductionAsync(
            CityFragment city,
            int restoranasId,
            int porcijaId,
            int portionQty,
            int? tableNumber = null,
            string? phone = null,
            string? deliveryAddress = null,
            string? idempotencyKey = null,
            bool simulateM1Failure = false)
        {
            if (restoranasId <= 0)
                throw new ArgumentException("Restorano ID turi būti > 0.", nameof(restoranasId));
            if (porcijaId <= 0)
                throw new ArgumentException("Porcijos ID turi būti > 0.", nameof(porcijaId));
            if (portionQty <= 0)
                throw new ArgumentException("Porcijų kiekis turi būti > 0.", nameof(portionQty));
            if (tableNumber.HasValue && tableNumber.Value <= 0)
                throw new ArgumentException("Stalelio nr. turi būti > 0.", nameof(tableNumber));

            // 1. Route directly to the specified city horizontal fragment and verify restaurant exists there
            var target = _router.GetTarget(city);
            if (!await _router.RestaurantExistsInCityAsync(city, restoranasId))
            {
                Console.WriteLine($"Restoranas ({city}, restoranas_id={restoranasId}) nerastas {city} fragmente ({target.MySqlDatabaseName}).");
                return null;
            }

            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL INSERT (Kliento užsakymas + Produktų nurašymas) -> {target.City} fragmentas ===");

            // 2. Lookup portion price & recipe in M1
            decimal unitPrice;
            int receptasId;
            string recipeName;
            await using (var conn = new MySqlConnection(target.MySqlConnString))
            {
                await conn.OpenAsync();
                const string sql = @"
                    SELECT p.kaina, p.receptas_id, r.pavadinimas
                    FROM porcija p
                    JOIN receptas r ON r.receptas_id = p.receptas_id
                    WHERE p.porcija_id = @pid;";
                await using var cmd = new MySqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@pid", porcijaId);
                await using var reader = await cmd.ExecuteReaderAsync();
                if (!await reader.ReadAsync())
                {
                    Console.WriteLine($"Porcija porcija_id={porcijaId} nerasta {target.MySqlDatabaseName}.");
                    return null;
                }
                unitPrice = reader.GetDecimal("kaina");
                receptasId = reader.GetInt32("receptas_id");
                recipeName = reader.GetString("pavadinimas");
            }

            // 3. Find linked ingredients in M2 via RediSearch (FT.SEARCH idx:naudojamas_produktas)
            var usedDocs = await RedisIndexService.SearchHashesAsync(
                target.RedisDb,
                RedisIndexService.IdxNaudojamasProduktas,
                $"@receptas_id:[{receptasId} {receptasId}]",
                limit: 50);

            var deductions = new List<(RedisKey Key, decimal Qty)>();
            foreach (var doc in usedDocs)
            {
                if (doc.Fields.TryGetValue("produktas_id", out var pidStr) &&
                    doc.Fields.TryGetValue("kiekis", out var qtyStr) &&
                    decimal.TryParse(qtyStr, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal perPortion))
                {
                    deductions.Add((new RedisKey($"produktas:{pidStr}"), perPortion * portionQty));
                }
            }

            // 4. Idempotency check with TTL (city-scoped)
            string txKey = $"tx:idemp:order:{city}:{idempotencyKey ?? Guid.NewGuid().ToString("N")}";
            bool acquired = await target.RedisDb.StringSetAsync(txKey, "IN_PROGRESS", IdempotencyTtl, When.NotExists);
            if (!acquired)
            {
                var existing = await target.RedisDb.StringGetAsync(txKey);
                Console.WriteLine($"[Idempotency] Užsakymas su raktu '{txKey}' jau apdorotas ({existing}).");
                return null;
            }

            // 5. Step 1 (M2 Redis Server-Side Atomic Lua Script): check & deduct stock
            bool stockDeducted = false;
            if (deductions.Count > 0)
            {
                var keys = deductions.Select(d => d.Key).ToArray();
                var argv = deductions.Select(d => (RedisValue)d.Qty.ToString("0.###", CultureInfo.InvariantCulture)).ToArray();

                var luaRes = (RedisResult[]?)await target.RedisDb.ScriptEvaluateAsync(LuaCheckAndDeductStock, keys, argv);
                if (luaRes == null || luaRes.Length == 0 || (int)luaRes[0] != 1)
                {
                    string reason = luaRes != null && luaRes.Length > 1 ? string.Join(" ", luaRes.Select(x => x.ToString())) : "Unknown Lua error";
                    await target.RedisDb.KeyDeleteAsync(txKey);
                    Console.WriteLine($"[ATMESTA M2] Nepakanka produktų atsargų receptui '{recipeName}' (receptas_id={receptasId}): {reason}");
                    return null;
                }
                stockDeducted = true;
                Console.WriteLine($"[1/2] M2 ({target.RedisEndpoint}): atominiu Lua skriptu nurašyta {deductions.Count} produktų receptui '{recipeName}'.");
            }
            else
            {
                Console.WriteLine($"[1/2] M2 ({target.RedisEndpoint}): receptas_id={receptasId} neturi susietų produktų įrašų; atsargos nekeistos.");
            }

            // 6. Step 2 (M1 MySQL local ACID transaction with Retry)
            int newOrderId = await _router.GetNextCityMySqlIdAsync(city, "kliento_uzsakymas", "kliento_uzsakymas_id");
            int newLineId = await _router.GetNextCityMySqlIdAsync(city, "kliento_eilute", "kliento_eilute_id");
            long orderNr = 1000000000000000L + newOrderId;
            decimal totalCost = unitPrice * portionQty;

            const int maxAttempts = 2;
            Exception? lastM1Err = null;
            for (int attempt = 1; attempt <= maxAttempts; attempt++)
            {
                try
                {
                    if (simulateM1Failure)
                        throw new InvalidOperationException("Imituotas M1 (MySQL) gedimas demonstracijai.");

                    await using var conn = new MySqlConnection(target.MySqlConnString);
                    await conn.OpenAsync();
                    await using var tx = await conn.BeginTransactionAsync();

                    const string insertOrderSql = @"
                        INSERT INTO kliento_uzsakymas (kliento_uzsakymas_id, uzsakymo_nr, kaina, stalelis, telefonas, pristatymo_adresas, restoranas_id)
                        VALUES (@id, @nr, @kaina, @stal, @tel, @adr, @rid);";
                    await using (var cmdOrder = new MySqlCommand(insertOrderSql, conn, tx))
                    {
                        cmdOrder.Parameters.AddWithValue("@id", newOrderId);
                        cmdOrder.Parameters.AddWithValue("@nr", orderNr);
                        cmdOrder.Parameters.AddWithValue("@kaina", totalCost);
                        cmdOrder.Parameters.AddWithValue("@stal", tableNumber.HasValue ? tableNumber.Value : DBNull.Value);
                        cmdOrder.Parameters.AddWithValue("@tel", string.IsNullOrWhiteSpace(phone) ? DBNull.Value : phone.Trim());
                        cmdOrder.Parameters.AddWithValue("@adr", string.IsNullOrWhiteSpace(deliveryAddress) ? DBNull.Value : deliveryAddress.Trim());
                        cmdOrder.Parameters.AddWithValue("@rid", restoranasId);
                        await cmdOrder.ExecuteNonQueryAsync();
                    }

                    const string insertLineSql = @"
                        INSERT INTO kliento_eilute (kliento_eilute_id, kaina, kiekis, kliento_uzsakymas_id, porcija_id)
                        VALUES (@lid, @kaina, @kiekis, @oid, @pid);";
                    await using (var cmdLine = new MySqlCommand(insertLineSql, conn, tx))
                    {
                        cmdLine.Parameters.AddWithValue("@lid", newLineId);
                        cmdLine.Parameters.AddWithValue("@kaina", totalCost);
                        cmdLine.Parameters.AddWithValue("@kiekis", portionQty);
                        cmdLine.Parameters.AddWithValue("@oid", newOrderId);
                        cmdLine.Parameters.AddWithValue("@pid", porcijaId);
                        await cmdLine.ExecuteNonQueryAsync();
                    }

                    await tx.CommitAsync();
                    await target.RedisDb.StringSetAsync(txKey, $"COMPLETED:{newOrderId}", IdempotencyTtl);
                    Console.WriteLine($"[2/2] M1 ({target.MySqlDatabaseName}): įterptas užsakymas #{newOrderId} (nr={orderNr}, suma={totalCost:F2}€).");
                    return newOrderId;
                }
                catch (Exception ex)
                {
                    lastM1Err = ex;
                    Console.WriteLine($"[Įspėjimas M1] Bandymas {attempt}/{maxAttempts} nepavyko: {ex.Message}");
                    if (attempt < maxAttempts)
                        await Task.Delay(150);
                }
            }

            // 7. Saga Compensation: restore Redis stock via Lua script if MySQL failed
            if (stockDeducted)
            {
                Console.WriteLine($"[KOMPENSACIJA] M1 nepavyko ({lastM1Err?.Message}). Grąžinami nurašyti produktai į M2 ({target.RedisEndpoint})...");
                var keys = deductions.Select(d => d.Key).ToArray();
                var argv = deductions.Select(d => (RedisValue)d.Qty.ToString("0.###", CultureInfo.InvariantCulture)).ToArray();
                await target.RedisDb.ScriptEvaluateAsync(LuaRestoreStock, keys, argv);
                Console.WriteLine("[KOMPENSACIJA SĖKMINGA] Produktų likučiai M2 atstatyti.");
            }
            await target.RedisDb.KeyDeleteAsync(txKey);
            return null;
        }
    }
}
