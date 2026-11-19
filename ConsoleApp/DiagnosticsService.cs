using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using MySqlConnector;
using StackExchange.Redis;

namespace ConsoleApp
{
    /// <summary>
    /// Provides distributed data integrity verification across all 4 fragments
    /// (M1 MySQL Kaunas/Vilnius and M2 Redis Kaunas/Vilnius) as well as
    /// performance benchmarking using Stopwatch on test data.
    /// </summary>
    public sealed class DiagnosticsService
    {
        private readonly ShardRouter _router;

        private sealed record BenchmarkStats(
            string Scenario,
            int Iterations,
            double TotalMs,
            double AvgMs,
            double MinMs,
            double MaxMs);

        public DiagnosticsService(ShardRouter router)
        {
            _router = router;
        }

        /// <summary>
        /// Verifies horizontal sharding predicates, vertical 1:1 restaurant consistency,
        /// cross-vertical referential integrity (M2 -> M1 and M2 -> M2), and domain constraints
        /// across all 4 distributed fragments.
        /// </summary>
        public async Task<bool> VerifyIntegrityAsync()
        {
            Console.WriteLine();
            Console.WriteLine("=== GLOBALUS VIENTISUMO PATIKRINIMAS (M1 MySQL <-> M2 Redis, Kaunas ir Vilnius) ===");

            int totalViolations = 0;

            foreach (var target in _router.GetTargets(null))
            {
                string expectedCity = target.City.ToString();
                int cityViolations = 0;

                // 1. Load M1 reference sets (restoranas, receptas, invalid order lines)
                var m1Restaurants = new Dictionary<int, (string Name, string City)>();
                var m1Recipes = new HashSet<int>();
                int invalidOrderLines = 0;

                await using (var conn = new MySqlConnection(target.MySqlConnString))
                {
                    await conn.OpenAsync();

                    await using (var cmd = new MySqlCommand(
                        "SELECT restoranas_id, pavadinimas, vietove FROM restoranas;", conn))
                    await using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            m1Restaurants[reader.GetInt32("restoranas_id")] = (
                                reader.GetString("pavadinimas"),
                                reader.GetString("vietove"));
                        }
                    }

                    await using (var cmd = new MySqlCommand("SELECT receptas_id FROM receptas;", conn))
                    await using (var reader = await cmd.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            m1Recipes.Add(reader.GetInt32("receptas_id"));
                        }
                    }

                    await using (var cmd = new MySqlCommand(
                        "SELECT COUNT(*) FROM kliento_eilute WHERE kiekis <= 0 OR kaina < 0;", conn))
                    {
                        invalidOrderLines = Convert.ToInt32(await cmd.ExecuteScalarAsync());
                    }
                }

                // 2. Load M2 documents via RediSearch indexes
                var m2RestDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxRestoranas, "*", limit: 10000);
                var m2InvDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxInventorius, "*", limit: 10000);
                var m2ProdDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxProduktas, "*", limit: 10000);
                var m2NpDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxNaudojamasProduktas, "*", limit: 10000);
                var m2RestOrderDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxRestoranoUzsakymas, "*", limit: 10000);
                var m2OrderLineDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxUzsakymoEilute, "*", limit: 10000);

                var m2Restaurants = new Dictionary<int, (string Name, string City)>();
                foreach (var doc in m2RestDocs)
                {
                    if (TryGetInt(doc, "restoranas_id", out int rid))
                    {
                        doc.Fields.TryGetValue("pavadinimas", out var rName);
                        doc.Fields.TryGetValue("vietove", out var rCity);
                        m2Restaurants[rid] = (rName ?? "", rCity ?? "");
                    }
                }

                var m2ProductIds = new HashSet<int>();
                int negativeProdStock = 0;
                int orphanProdToRest = 0;
                foreach (var doc in m2ProdDocs)
                {
                    if (TryGetInt(doc, "produktas_id", out int pid))
                        m2ProductIds.Add(pid);
                    if (!TryGetInt(doc, "restoranas_id", out int rid) || !m1Restaurants.ContainsKey(rid))
                        orphanProdToRest++;
                    if (TryGetDecimal(doc, "kiekis", out decimal qty) && qty < 0)
                        negativeProdStock++;
                }

                int negativeInvQty = 0;
                int orphanInvToRest = 0;
                foreach (var doc in m2InvDocs)
                {
                    if (!TryGetInt(doc, "restoranas_id", out int rid) || !m1Restaurants.ContainsKey(rid))
                        orphanInvToRest++;
                    if (TryGetDecimal(doc, "kiekis", out decimal qty) && qty < 0)
                        negativeInvQty++;
                }

                int linkedNpToLocalRecipe = 0;
                int orphanNpToProduct = 0;
                foreach (var doc in m2NpDocs)
                {
                    if (TryGetInt(doc, "receptas_id", out int recId) && m1Recipes.Contains(recId))
                        linkedNpToLocalRecipe++;
                    if (!TryGetInt(doc, "produktas_id", out int pid) || !m2ProductIds.Contains(pid))
                        orphanNpToProduct++;
                }

                var m2RestOrderIds = new HashSet<int>();
                foreach (var doc in m2RestOrderDocs)
                {
                    if (TryGetInt(doc, "restorano_uzsakymas_id", out int roid))
                        m2RestOrderIds.Add(roid);
                }

                int orphanLineToRestOrder = 0;
                foreach (var doc in m2OrderLineDocs)
                {
                    if (!TryGetInt(doc, "restorano_uzsakymas_id", out int roid) || !m2RestOrderIds.Contains(roid))
                        orphanLineToRestOrder++;
                }

                // Check horizontal predicate vietove and vertical 1:1 M1 <-> M2 consistency
                int wrongM1City = m1Restaurants.Values.Count(v => !string.Equals(v.City, expectedCity, StringComparison.OrdinalIgnoreCase));
                int wrongM2City = m2Restaurants.Values.Count(v => !string.Equals(v.City, expectedCity, StringComparison.OrdinalIgnoreCase));
                int missingInM2 = m1Restaurants.Keys.Count(id => !m2Restaurants.ContainsKey(id));
                int missingInM1 = m2Restaurants.Keys.Count(id => !m1Restaurants.ContainsKey(id));
                int nameMismatches = m1Restaurants
                    .Where(kv => m2Restaurants.TryGetValue(kv.Key, out var m2Val) &&
                                 !string.Equals(kv.Value.Name, m2Val.Name, StringComparison.Ordinal))
                    .Count();

                cityViolations = wrongM1City + wrongM2City + missingInM2 + missingInM1 + nameMismatches +
                                 orphanInvToRest + orphanProdToRest + orphanNpToProduct +
                                 orphanLineToRestOrder + negativeProdStock + negativeInvQty + invalidOrderLines;
                totalViolations += cityViolations;

                Console.WriteLine();
                Console.WriteLine($"Fragmentas [{expectedCity}] (M1: {target.MySqlDatabaseName}, M2: {target.RedisEndpoint}):");
                Console.WriteLine($"  • Horizontalus predikatas (vietove='{expectedCity}'): M1 pažeidimų={wrongM1City}, M2 pažeidimų={wrongM2City} (tikrinta M1={m1Restaurants.Count}, M2={m2Restaurants.Count})");
                Console.WriteLine($"  • Vertikalus 1:1 atitikimas (M1<->M2 restoranas): trūksta M2={missingInM2}, trūksta M1={missingInM1}, pavadinimų nesutapimų={nameMismatches}");
                Console.WriteLine($"  • Kryžminis nuorodinis vientisumas: inventorius->restoranas={orphanInvToRest}, produktas->restoranas={orphanProdToRest}, naudojamas_produktas->produktas(M2)={orphanNpToProduct}, uzsakymo_eilute->restorano_uzsakymas={orphanLineToRestOrder}");
                Console.WriteLine($"  • Receptų nuorodų statistika (informacinė): naudojamas_produktas susietų su šio fragmento M1 receptas={linkedNpToLocalRecipe}/{m2NpDocs.Count}");
                Console.WriteLine($"  • Domeno / kiekio apribojimai: neigiamų produktas kiekis={negativeProdStock}, neigiamų inventorius kiekis={negativeInvQty}, neteisingų kliento_eilute={invalidOrderLines}");
                Console.WriteLine($"  => Būsena [{expectedCity}]: {(cityViolations == 0 ? "GALIOJA (0 pažeidimų)" : $"PAŽEISTA ({cityViolations} pažeidimų)")}");
            }

            Console.WriteLine();
            Console.WriteLine(totalViolations == 0
                ? "Vientisumo patikrinimas SĖKMINGAS: visi 4 fragmentai suderinti (0 pažeidimų)."
                : $"Vientisumo patikrinimas APTIKO KLAIDŲ: iš viso {totalViolations} pažeidimų.");

            return totalViolations == 0;
        }

        /// <summary>
        /// Measures performance on test data across 4 distributed database scenarios using Stopwatch.
        /// </summary>
        public async Task RunPerformanceBenchmarkAsync(GlobalQueryService queryService, GlobalInsertService insertService)
        {
            Console.WriteLine();
            Console.WriteLine("=== NAŠUMO MATAVIMAS (Testiniai duomenys: M1 MySQL + M2 Redis Stack) ===");

            var kaunas = _router.GetTarget(CityFragment.Kaunas);
            var statsList = new List<BenchmarkStats>();

            // Prepare 15 product keys for Scenario 1
            var sampleProdDocs = await RedisIndexService.SearchHashesAsync(
                kaunas.RedisDb, RedisIndexService.IdxProduktas, "*", limit: 15);
            var productKeys = sampleProdDocs.Select(d => (RedisKey)d.Key).ToArray();

            // Scenario 1: Redis Pipelining (IBatch) vs Sequential HGETALL
            statsList.Add(await MeasureAsync(
                $"M2 Sequential HGETALL ({productKeys.Length} raktų)",
                iterations: 30,
                async () =>
                {
                    foreach (var key in productKeys)
                        await kaunas.RedisDb.HashGetAllAsync(key);
                }));

            statsList.Add(await MeasureAsync(
                $"M2 Pipelined IBatch HGETALL ({productKeys.Length} raktų)",
                iterations: 30,
                async () =>
                {
                    IBatch batch = kaunas.RedisDb.CreateBatch();
                    var tasks = new Task<HashEntry[]>[productKeys.Length];
                    for (int i = 0; i < productKeys.Length; i++)
                        tasks[i] = batch.HashGetAllAsync(productKeys[i]);
                    batch.Execute();
                    await Task.WhenAll(tasks);
                }));

            // Scenario 2: RediSearch Index (FT.SEARCH) vs Full Key SCAN + HGETALL
            var redisServer = _router.RedisM2Kaunas.GetServer(_router.RedisM2Kaunas.GetEndPoints()[0]);
            statsList.Add(await MeasureAsync(
                "M2 Full Key SCAN + HGETALL (inventorius:*, filtras restoranas_id=1)",
                iterations: 30,
                async () =>
                {
                    int matches = 0;
                    await foreach (var key in redisServer.KeysAsync(pattern: "inventorius:*", pageSize: 250))
                    {
                        var val = await kaunas.RedisDb.HashGetAsync(key, "restoranas_id");
                        if (val == "1")
                            matches++;
                    }
                }));

            statsList.Add(await MeasureAsync(
                "M2 RediSearch FT.SEARCH (@restoranas_id:[1 1])",
                iterations: 30,
                async () =>
                {
                    _ = await RedisIndexService.SearchHashesAsync(
                        kaunas.RedisDb, RedisIndexService.IdxInventorius, "@restoranas_id:[1 1]", limit: 100);
                }));

            // Scenario 3: Single-Shard Global SELECT vs Scatter-Gather Global SELECT (M1 + M2)
            statsList.Add(await MeasureAsync(
                "Global SELECT (Single-Shard: Kaunas, M1+M2)",
                iterations: 15,
                async () =>
                {
                    await RunMutedAsync(() => queryService.SelectRestaurantsGlobalAsync(CityFragment.Kaunas, null, limit: 100));
                }));

            statsList.Add(await MeasureAsync(
                "Global SELECT (Scatter-Gather: Kaunas+Vilnius, M1+M2)",
                iterations: 15,
                async () =>
                {
                    await RunMutedAsync(() => queryService.SelectRestaurantsGlobalAsync(null, null, limit: 100));
                }));

            // Scenario 4: Distributed Saga Write & Saga Compensation Recovery (porcija_id=16, Kaunas)
            const int testRestId = 45;
            const int testPortionId = 16;
            int? recipeId = null;
            await using (var conn = new MySqlConnection(kaunas.MySqlConnString))
            {
                await conn.OpenAsync();
                await using var cmd = new MySqlCommand("SELECT receptas_id FROM porcija WHERE porcija_id = @pid;", conn);
                cmd.Parameters.AddWithValue("@pid", testPortionId);
                var scalar = await cmd.ExecuteScalarAsync();
                if (scalar is not null && scalar != DBNull.Value)
                    recipeId = Convert.ToInt32(scalar);
            }

            var savedStocks = new Dictionary<string, RedisValue>();
            if (recipeId.HasValue)
            {
                var ingDocs = await RedisIndexService.SearchHashesAsync(
                    kaunas.RedisDb, RedisIndexService.IdxNaudojamasProduktas, $"@receptas_id:[{recipeId.Value} {recipeId.Value}]", limit: 20);
                foreach (var ing in ingDocs)
                {
                    if (ing.Fields.TryGetValue("produktas_id", out var pidStr))
                    {
                        string pKey = $"produktas:{pidStr}";
                        savedStocks[pKey] = await kaunas.RedisDb.HashGetAsync(pKey, "kiekis");
                    }
                }
            }

            int sagaCounter = 0;
            var createdOrderIds = new List<int>();
            statsList.Add(await MeasureAsync(
                "Distributed Saga INSERT Order (M2 Lua + M1 ACID)",
                iterations: 5,
                async () =>
                {
                    int idx = ++sagaCounter;
                    string idemp = $"bench-ok-{idx}-{Guid.NewGuid():N}";
                    int? oid = await RunMutedAsync(() => insertService.InsertCustomerOrderWithStockDeductionAsync(
                        CityFragment.Kaunas, testRestId, testPortionId, 1,
                        tableNumber: 1, idempotencyKey: idemp, simulateM1Failure: false));
                    if (oid.HasValue)
                        createdOrderIds.Add(oid.Value);
                    await kaunas.RedisDb.KeyDeleteAsync($"tx:idemp:order:Kaunas:{idemp}");
                },
                warmupIterations: 1));

            int failCounter = 0;
            statsList.Add(await MeasureAsync(
                "Distributed Saga Failure + Lua Compensation Recovery",
                iterations: 5,
                async () =>
                {
                    int idx = ++failCounter;
                    string idemp = $"bench-fail-{idx}-{Guid.NewGuid():N}";
                    _ = await RunMutedAsync(() => insertService.InsertCustomerOrderWithStockDeductionAsync(
                        CityFragment.Kaunas, testRestId, testPortionId, 1,
                        tableNumber: 1, idempotencyKey: idemp, simulateM1Failure: true));
                    await kaunas.RedisDb.KeyDeleteAsync($"tx:idemp:order:Kaunas:{idemp}");
                },
                warmupIterations: 1));

            // Cleanup benchmark orders and restore exact initial product stock
            if (createdOrderIds.Count > 0)
            {
                await using var conn = new MySqlConnection(kaunas.MySqlConnString);
                await conn.OpenAsync();
                foreach (int oid in createdOrderIds)
                {
                    await using var cmd = new MySqlCommand(
                        "DELETE FROM kliento_uzsakymas WHERE kliento_uzsakymas_id = @id;", conn);
                    cmd.Parameters.AddWithValue("@id", oid);
                    await cmd.ExecuteNonQueryAsync();
                }
            }
            foreach (var kv in savedStocks)
                await kaunas.RedisDb.HashSetAsync(kv.Key, "kiekis", kv.Value);

            // Print formatted results table
            Console.WriteLine();
            Console.WriteLine($"{"Scenarijus",-62} | {"Iter.",5} | {"Viso (ms)",10} | {"Vid. (ms)",10} | {"Min (ms)",9} | {"Max (ms)",9}");
            Console.WriteLine(new string('-', 120));
            foreach (var s in statsList)
            {
                Console.WriteLine(
                    $"{s.Scenario,-62} | {s.Iterations,5} | {s.TotalMs,10:F2} | {s.AvgMs,10:F2} | {s.MinMs,9:F2} | {s.MaxMs,9:F2}");
            }
        }

        private static async Task<BenchmarkStats> MeasureAsync(
            string scenario,
            int iterations,
            Func<Task> action,
            int warmupIterations = 2)
        {
            for (int w = 0; w < warmupIterations; w++)
                await action();

            var timings = new double[iterations];
            var sw = new Stopwatch();
            for (int i = 0; i < iterations; i++)
            {
                sw.Restart();
                await action();
                sw.Stop();
                timings[i] = sw.Elapsed.TotalMilliseconds;
            }

            double total = timings.Sum();
            return new BenchmarkStats(
                scenario,
                iterations,
                total,
                total / iterations,
                timings.Min(),
                timings.Max());
        }

        private static async Task RunMutedAsync(Func<Task> action)
        {
            var prevOut = Console.Out;
            try
            {
                Console.SetOut(TextWriter.Null);
                await action();
            }
            finally
            {
                Console.SetOut(prevOut);
            }
        }

        private static async Task<T> RunMutedAsync<T>(Func<Task<T>> action)
        {
            var prevOut = Console.Out;
            try
            {
                Console.SetOut(TextWriter.Null);
                return await action();
            }
            finally
            {
                Console.SetOut(prevOut);
            }
        }

        private static bool TryGetInt(RedisHashDoc doc, string field, out int value)
        {
            if (doc.Fields.TryGetValue(field, out var raw) && int.TryParse(raw, out value))
                return true;
            value = 0;
            return false;
        }

        private static bool TryGetDecimal(RedisHashDoc doc, string field, out decimal value)
        {
            if (doc.Fields.TryGetValue(field, out var raw) &&
                decimal.TryParse(raw, NumberStyles.Any, CultureInfo.InvariantCulture, out value))
                return true;
            value = 0m;
            return false;
        }
    }
}
