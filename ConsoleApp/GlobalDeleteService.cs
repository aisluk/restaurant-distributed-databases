using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MySqlConnector;
using StackExchange.Redis;

namespace ConsoleApp
{
    /// <summary>
    /// Implements global cascading DELETE operations spanning M1 (MySQL) and M2 (Redis)
    /// within a single horizontal fragment (Kaunas or Vilnius).
    /// Removes the restaurant and all directly or indirectly orphaned records while
    /// preserving reference/lookup entities (dieta, porcijos_dydis, tiekejas).
    /// </summary>
    public sealed class GlobalDeleteService
    {
        private readonly ShardRouter _router;
        private static readonly TimeSpan IdempotencyTtl = TimeSpan.FromMinutes(10);

        public GlobalDeleteService(ShardRouter router)
        {
            _router = router;
        }

        /// <summary>
        /// Deletes a restaurant and cascades deletion to all directly and indirectly orphaned entities
        /// across M2 (Redis) and M1 (MySQL):
        /// - M2: restoranas:{id}, inventorius, produktas, naudojamas_produktas, uzsakymo_eilute,
        ///       and orphaned restorano_uzsakymas (keeps tiekejas).
        /// - M1: darbuotojas, kliento_uzsakymas, kliento_eilute, orphaned receptas & porcija
        ///       (keeps dieta and porcijos_dydis).
        /// Coordination: Idempotency TTL -> M2 snapshot + MULTI/EXEC delete -> M1 ACID delete -> M2 snapshot restore on failure.
        /// </summary>
        public async Task<bool> DeleteRestaurantCascadeAsync(
            CityFragment city,
            int restoranasId,
            string? idempotencyKey = null,
            bool simulateM1Failure = false)
        {
            if (restoranasId <= 0)
                throw new ArgumentException("Restorano ID turi būti > 0.", nameof(restoranasId));

            var target = _router.GetTarget(city);
            string cityStr = city.ToString();

            if (!await _router.RestaurantExistsInCityAsync(city, restoranasId))
            {
                Console.WriteLine($"Restoranas ({cityStr}, restoranas_id={restoranasId}) nerastas {target.MySqlDatabaseName}.");
                return false;
            }

            string txKey = $"tx:idemp:rest-del:{cityStr}:{idempotencyKey ?? Guid.NewGuid().ToString("N")}";

            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL DELETE (Restoranas + Kaskadinis našlaičių šalinimas) -> Fragmentas: {cityStr}, restoranas_id={restoranasId} ===");

            // 0. Idempotency check with Redis TTL
            bool acquired = await target.RedisDb.StringSetAsync(txKey, "IN_PROGRESS", IdempotencyTtl, When.NotExists);
            if (!acquired)
            {
                var existing = await target.RedisDb.StringGetAsync(txKey);
                Console.WriteLine($"[Idempotency] Operacija su raktu '{txKey}' jau užregistruota (būsena: {existing}). Pakartotinis šalinimas sustabdytas.");
                return false;
            }

            // 1. Discover all M2 keys to delete (direct + indirect orphans)
            var invDocs = await RedisIndexService.SearchHashesAsync(
                target.RedisDb, RedisIndexService.IdxInventorius, $"@restoranas_id:[{restoranasId} {restoranasId}]", limit: 5000);
            var prodDocs = await RedisIndexService.SearchHashesAsync(
                target.RedisDb, RedisIndexService.IdxProduktas, $"@restoranas_id:[{restoranasId} {restoranasId}]", limit: 5000);

            var deletedInvIds = ParseIds(invDocs, "inventorius_id");
            var deletedProdIds = ParseIds(prodDocs, "produktas_id");

            // Find naudojamas_produktas referencing deleted products, and compute orphaned receptas_id
            var npToDelete = new List<RedisHashDoc>();
            var affectedRecipeIds = new HashSet<int>();
            var remainingByRecipe = new Dictionary<int, int>();
            {
                var allNp = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxNaudojamasProduktas, "*", limit: 10000);

                foreach (var doc in allNp)
                {
                    if (!TryGetInt(doc, "produktas_id", out int prodId) ||
                        !TryGetInt(doc, "receptas_id", out int recId))
                        continue;

                    if (deletedProdIds.Contains(prodId))
                    {
                        npToDelete.Add(doc);
                        affectedRecipeIds.Add(recId);
                    }
                    else
                    {
                        remainingByRecipe[recId] = remainingByRecipe.GetValueOrDefault(recId) + 1;
                    }
                }

                // Keep only recipes that have 0 remaining naudojamas_produktas entries
                affectedRecipeIds.RemoveWhere(recId => remainingByRecipe.GetValueOrDefault(recId) > 0);
            }

            // Find uzsakymo_eilute referencing deleted inventorius or produktas, and compute orphaned restorano_uzsakymas_id
            var orderLinesToDelete = new List<RedisHashDoc>();
            var orphanedRestOrderIds = new HashSet<int>();
            if (deletedInvIds.Count > 0 || deletedProdIds.Count > 0)
            {
                var allLines = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxUzsakymoEilute, "*", limit: 10000);

                var remainingLinesByOrder = new Dictionary<int, int>();
                foreach (var doc in allLines)
                {
                    if (!TryGetInt(doc, "restorano_uzsakymas_id", out int restOrdId))
                        continue;

                    bool matchesInv = TryGetInt(doc, "inventorius_id", out int invId) && deletedInvIds.Contains(invId);
                    bool matchesProd = TryGetInt(doc, "produktas_id", out int prodId) && deletedProdIds.Contains(prodId);

                    if (matchesInv || matchesProd)
                    {
                        orderLinesToDelete.Add(doc);
                        orphanedRestOrderIds.Add(restOrdId);
                    }
                    else
                    {
                        remainingLinesByOrder[restOrdId] = remainingLinesByOrder.GetValueOrDefault(restOrdId) + 1;
                    }
                }

                // Keep only restorano_uzsakymas that have 0 remaining uzsakymo_eilute entries
                orphanedRestOrderIds.RemoveWhere(ordId => remainingLinesByOrder.GetValueOrDefault(ordId) > 0);
            }

            // Collect all Redis keys to delete
            var keysToDelete = new List<RedisKey>();
            string restKey = $"restoranas:{restoranasId}";
            if (await target.RedisDb.KeyExistsAsync(restKey))
                keysToDelete.Add(restKey);
            keysToDelete.AddRange(invDocs.Select(d => (RedisKey)d.Key));
            keysToDelete.AddRange(prodDocs.Select(d => (RedisKey)d.Key));
            keysToDelete.AddRange(npToDelete.Select(d => (RedisKey)d.Key));
            keysToDelete.AddRange(orderLinesToDelete.Select(d => (RedisKey)d.Key));
            foreach (int ordId in orphanedRestOrderIds)
            {
                string ordKey = $"restorano_uzsakymas:{ordId}";
                if (await target.RedisDb.KeyExistsAsync(ordKey))
                    keysToDelete.Add(ordKey);
            }
            keysToDelete = keysToDelete.Distinct().ToList();

            // 2. Snapshot M2 hashes before deleting so we can compensate if M1 fails
            var m2Snapshot = new Dictionary<RedisKey, HashEntry[]>(keysToDelete.Count);
            foreach (var key in keysToDelete)
            {
                var entries = await target.RedisDb.HashGetAllAsync(key);
                if (entries.Length > 0)
                    m2Snapshot[key] = entries;
            }

            // 3. Step 1: Delete from M2 (Redis MULTI/EXEC)
            if (keysToDelete.Count > 0)
            {
                var redisTx = target.RedisDb.CreateTransaction();
                foreach (var key in keysToDelete)
                    _ = redisTx.KeyDeleteAsync(key);
                bool committed = await redisTx.ExecuteAsync();
                if (!committed)
                {
                    await target.RedisDb.KeyDeleteAsync(txKey);
                    Console.WriteLine($"[KLAIDA M2] Redis MULTI/EXEC šalinimas neįvyko.");
                    return false;
                }
            }

            Console.WriteLine(
                $"[1/2] M2 ({target.RedisEndpoint}): pašalinta restoranas={restoranasId}, inventorius={invDocs.Count}, " +
                $"produktas={prodDocs.Count}, naudojamas_produktas={npToDelete.Count}, uzsakymo_eilute={orderLinesToDelete.Count}, " +
                $"restorano_uzsakymas={orphanedRestOrderIds.Count} (tiekejas išsaugotas).");

            // 4. Step 2: Delete from M1 (MySQL local ACID transaction)
            try
            {
                if (simulateM1Failure)
                    throw new InvalidOperationException("Imituotas M1 (MySQL) mazgo gedimas demonstracijai.");

                await using var conn = new MySqlConnection(target.MySqlConnString);
                await conn.OpenAsync();
                await using var tx = await conn.BeginTransactionAsync();

                // Find any recipes linked via this restaurant's orders/portions before deleting kliento_eilute
                const string orderRecipesSql = @"
                    SELECT DISTINCT p.receptas_id
                    FROM porcija p
                    JOIN kliento_eilute ke ON ke.porcija_id = p.porcija_id
                    JOIN kliento_uzsakymas ku ON ku.kliento_uzsakymas_id = ke.kliento_uzsakymas_id
                    WHERE ku.restoranas_id = @rid;";
                var orderLinkedRecipes = new List<int>();
                await using (var recCmd = new MySqlCommand(orderRecipesSql, conn, tx))
                {
                    recCmd.Parameters.AddWithValue("@rid", restoranasId);
                    await using var reader = await recCmd.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                        orderLinkedRecipes.Add(reader.GetInt32(0));
                }

                foreach (int recId in orderLinkedRecipes)
                {
                    if (remainingByRecipe.GetValueOrDefault(recId) == 0 && !affectedRecipeIds.Contains(recId))
                    {
                        await using var chkCmd = new MySqlCommand(
                            @"SELECT COUNT(1)
                              FROM kliento_eilute ke
                              JOIN porcija p ON p.porcija_id = ke.porcija_id
                              JOIN kliento_uzsakymas ku ON ku.kliento_uzsakymas_id = ke.kliento_uzsakymas_id
                              WHERE p.receptas_id = @recId AND ku.restoranas_id <> @rid;",
                            conn, tx);
                        chkCmd.Parameters.AddWithValue("@recId", recId);
                        chkCmd.Parameters.AddWithValue("@rid", restoranasId);
                        if (Convert.ToInt32(await chkCmd.ExecuteScalarAsync()) == 0)
                            affectedRecipeIds.Add(recId);
                    }
                }

                int delCustLines = await ExecuteDeleteAsync(
                    conn, tx,
                    @"DELETE ke FROM kliento_eilute ke
                      JOIN kliento_uzsakymas ku ON ku.kliento_uzsakymas_id = ke.kliento_uzsakymas_id
                      WHERE ku.restoranas_id = @rid;",
                    restoranasId);

                int delCustOrders = await ExecuteDeleteAsync(
                    conn, tx,
                    "DELETE FROM kliento_uzsakymas WHERE restoranas_id = @rid;",
                    restoranasId);

                int delEmployees = await ExecuteDeleteAsync(
                    conn, tx,
                    "DELETE FROM darbuotojas WHERE restoranas_id = @rid;",
                    restoranasId);

                int delPortionLines = 0;
                int delPortions = 0;
                int delRecipes = 0;
                if (affectedRecipeIds.Count > 0)
                {
                    var recIds = affectedRecipeIds.ToList();

                    delPortionLines = await ExecuteDeleteInAsync(
                        conn, tx,
                        @"DELETE ke FROM kliento_eilute ke
                          JOIN porcija p ON p.porcija_id = ke.porcija_id
                          WHERE p.receptas_id IN ({0});",
                        recIds);

                    delPortions = await ExecuteDeleteInAsync(
                        conn, tx,
                        "DELETE FROM porcija WHERE receptas_id IN ({0});",
                        recIds);

                    delRecipes = await ExecuteDeleteInAsync(
                        conn, tx,
                        "DELETE FROM receptas WHERE receptas_id IN ({0});",
                        recIds);
                }

                int delRestaurants = await ExecuteDeleteAsync(
                    conn, tx,
                    "DELETE FROM restoranas WHERE restoranas_id = @rid;",
                    restoranasId);

                await tx.CommitAsync();
                await target.RedisDb.StringSetAsync(txKey, $"COMPLETED:{restoranasId}", IdempotencyTtl);

                Console.WriteLine(
                    $"[2/2] M1 ({target.MySqlDatabaseName}): pašalinta restoranas={delRestaurants}, darbuotojas={delEmployees}, " +
                    $"kliento_uzsakymas={delCustOrders}, kliento_eilute={delCustLines + delPortionLines}, " +
                    $"porcija={delPortions}, receptas={delRecipes} (dieta ir porcijos_dydis išsaugoti).");
                return true;
            }
            catch (Exception ex)
            {
                // 5. Saga Compensation: restore M2 hashes from snapshot
                Console.WriteLine($"[KOMPENSACIJA] M1 nepavyko ({ex.Message}). Atstatomi M2 įrašai iš momentinės kopijos...");
                try
                {
                    if (m2Snapshot.Count > 0)
                    {
                        var restoreTx = target.RedisDb.CreateTransaction();
                        foreach (var kv in m2Snapshot)
                            _ = restoreTx.HashSetAsync(kv.Key, kv.Value);
                        await restoreTx.ExecuteAsync();
                    }
                    await target.RedisDb.KeyDeleteAsync(txKey);
                    Console.WriteLine($"[KOMPENSACIJA SĖKMINGA] Atstatyta M2 raktų: {m2Snapshot.Count}. Globalus nuoseklumas išlaikytas.");
                }
                catch (Exception compEx)
                {
                    Console.WriteLine($"[KRITINĖ KLAIDA] Kompensacija nepavyko: {compEx.Message}. Reikia rankinio patikrinimo raktui {txKey}.");
                }
                return false;
            }
        }

        /// <summary>
        /// Deletes a recipe and cascades deletion only to its directly orphaned items:
        /// - M2: naudojamas_produktas entries with receptas_id = id (keeps produktas).
        /// - M1: porcija entries (and kliento_eilute referencing those portions) + receptas (keeps dieta and porcijos_dydis).
        /// Coordination: Idempotency TTL -> M2 snapshot + MULTI/EXEC delete -> M1 ACID delete -> M2 snapshot restore on failure.
        /// </summary>
        public async Task<bool> DeleteRecipeCascadeAsync(
            CityFragment city,
            int receptasId,
            string? idempotencyKey = null,
            bool simulateM1Failure = false)
        {
            if (receptasId <= 0)
                throw new ArgumentException("Recepto ID turi būti > 0.", nameof(receptasId));

            var target = _router.GetTarget(city);
            string cityStr = city.ToString();

            await using (var checkConn = new MySqlConnection(target.MySqlConnString))
            {
                await checkConn.OpenAsync();
                await using var checkCmd = new MySqlCommand(
                    "SELECT COUNT(1) FROM receptas WHERE receptas_id = @id;", checkConn);
                checkCmd.Parameters.AddWithValue("@id", receptasId);
                if (Convert.ToInt32(await checkCmd.ExecuteScalarAsync()) == 0)
                {
                    Console.WriteLine($"Receptas ({cityStr}, receptas_id={receptasId}) nerastas {target.MySqlDatabaseName}.");
                    return false;
                }
            }

            string txKey = $"tx:idemp:rec-del:{cityStr}:{idempotencyKey ?? Guid.NewGuid().ToString("N")}";

            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL DELETE (Receptas + Porcijos + Naudojami produktai) -> Fragmentas: {cityStr}, receptas_id={receptasId} ===");

            // 0. Idempotency check with Redis TTL
            bool acquired = await target.RedisDb.StringSetAsync(txKey, "IN_PROGRESS", IdempotencyTtl, When.NotExists);
            if (!acquired)
            {
                var existing = await target.RedisDb.StringGetAsync(txKey);
                Console.WriteLine($"[Idempotency] Operacija su raktu '{txKey}' jau užregistruota (būsena: {existing}). Pakartotinis šalinimas sustabdytas.");
                return false;
            }

            // 1. Find naudojamas_produktas entries in M2 for this recipe and snapshot them
            var npDocs = await RedisIndexService.SearchHashesAsync(
                target.RedisDb, RedisIndexService.IdxNaudojamasProduktas, $"@receptas_id:[{receptasId} {receptasId}]", limit: 5000);

            var m2Snapshot = new Dictionary<RedisKey, HashEntry[]>(npDocs.Count);
            foreach (var doc in npDocs)
            {
                var entries = await target.RedisDb.HashGetAllAsync(doc.Key);
                if (entries.Length > 0)
                    m2Snapshot[doc.Key] = entries;
            }

            // 2. Step 1: Delete naudojamas_produktas from M2 (Redis MULTI/EXEC)
            if (npDocs.Count > 0)
            {
                var redisTx = target.RedisDb.CreateTransaction();
                foreach (var doc in npDocs)
                    _ = redisTx.KeyDeleteAsync(doc.Key);
                bool committed = await redisTx.ExecuteAsync();
                if (!committed)
                {
                    await target.RedisDb.KeyDeleteAsync(txKey);
                    Console.WriteLine("[KLAIDA M2] Redis MULTI/EXEC šalinimas neįvyko.");
                    return false;
                }
            }

            Console.WriteLine($"[1/2] M2 ({target.RedisEndpoint}): pašalinta naudojamas_produktas={npDocs.Count} (produktas išsaugoti).");

            // 3. Step 2: Delete porcija (+ referencing kliento_eilute) and receptas from M1 (MySQL local ACID)
            try
            {
                if (simulateM1Failure)
                    throw new InvalidOperationException("Imituotas M1 (MySQL) mazgo gedimas demonstracijai.");

                await using var conn = new MySqlConnection(target.MySqlConnString);
                await conn.OpenAsync();
                await using var tx = await conn.BeginTransactionAsync();

                int delPortionLines = await ExecuteDeleteAsync(
                    conn, tx,
                    @"DELETE ke FROM kliento_eilute ke
                      JOIN porcija p ON p.porcija_id = ke.porcija_id
                      WHERE p.receptas_id = @rid;",
                    receptasId);

                int delPortions = await ExecuteDeleteAsync(
                    conn, tx,
                    "DELETE FROM porcija WHERE receptas_id = @rid;",
                    receptasId);

                int delRecipes = await ExecuteDeleteAsync(
                    conn, tx,
                    "DELETE FROM receptas WHERE receptas_id = @rid;",
                    receptasId);

                await tx.CommitAsync();
                await target.RedisDb.StringSetAsync(txKey, $"COMPLETED:{receptasId}", IdempotencyTtl);

                Console.WriteLine(
                    $"[2/2] M1 ({target.MySqlDatabaseName}): pašalinta receptas={delRecipes}, porcija={delPortions}, " +
                    $"kliento_eilute={delPortionLines} (dieta ir porcijos_dydis išsaugoti).");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[KOMPENSACIJA] M1 nepavyko ({ex.Message}). Atstatomi M2 naudojamas_produktas įrašai...");
                try
                {
                    if (m2Snapshot.Count > 0)
                    {
                        var restoreTx = target.RedisDb.CreateTransaction();
                        foreach (var kv in m2Snapshot)
                            _ = restoreTx.HashSetAsync(kv.Key, kv.Value);
                        await restoreTx.ExecuteAsync();
                    }
                    await target.RedisDb.KeyDeleteAsync(txKey);
                    Console.WriteLine($"[KOMPENSACIJA SĖKMINGA] Atstatyta M2 raktų: {m2Snapshot.Count}. Globalus nuoseklumas išlaikytas.");
                }
                catch (Exception compEx)
                {
                    Console.WriteLine($"[KRITINĖ KLAIDA] Kompensacija nepavyko: {compEx.Message}. Reikia rankinio patikrinimo raktui {txKey}.");
                }
                return false;
            }
        }

        private static HashSet<int> ParseIds(List<RedisHashDoc> docs, string field)
        {
            var ids = new HashSet<int>();
            foreach (var doc in docs)
            {
                if (TryGetInt(doc, field, out int id))
                    ids.Add(id);
            }
            return ids;
        }

        private static bool TryGetInt(RedisHashDoc doc, string field, out int value)
        {
            if (doc.Fields.TryGetValue(field, out var raw) && int.TryParse(raw, out value))
                return true;
            value = 0;
            return false;
        }

        private static async Task<int> ExecuteDeleteAsync(MySqlConnection conn, MySqlTransaction tx, string sql, int restoranasId)
        {
            await using var cmd = new MySqlCommand(sql, conn, tx);
            cmd.Parameters.AddWithValue("@rid", restoranasId);
            return await cmd.ExecuteNonQueryAsync();
        }

        private static async Task<int> ExecuteDeleteInAsync(MySqlConnection conn, MySqlTransaction tx, string sqlFormat, List<int> ids)
        {
            var paramNames = new string[ids.Count];
            await using var cmd = new MySqlCommand { Connection = conn, Transaction = tx };
            for (int i = 0; i < ids.Count; i++)
            {
                string p = $"@p{i}";
                paramNames[i] = p;
                cmd.Parameters.AddWithValue(p, ids[i]);
            }
            cmd.CommandText = string.Format(sqlFormat, string.Join(", ", paramNames));
            return await cmd.ExecuteNonQueryAsync();
        }
    }
}
