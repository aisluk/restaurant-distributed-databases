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
    /// Implements global SELECT operations that combine vertical fragments (M1 MySQL + M2 Redis)
    /// across the appropriate horizontal fragments (Kaunas / Vilnius or Scatter-Gather across both).
    /// Uses RediSearch (FT.SEARCH) and Redis Pipelining (IBatch).
    /// </summary>
    public sealed class GlobalQueryService
    {
        private readonly ShardRouter _router;

        public GlobalQueryService(ShardRouter router)
        {
            _router = router;
        }

        private sealed record M1RestaurantSummary(
            int RestoranasId,
            string Pavadinimas,
            string Vietove,
            string? Telefonas,
            int EmployeeCount,
            int OrderCount,
            decimal TotalRevenue);

        /// <summary>
        /// SELECT 1: Unified restaurant report joining M1 (employees, customer orders & revenue)
        /// with M2 (RediSearch FT.SEARCH on restaurants, inventory & products) by restoranas_id.
        /// </summary>
        public async Task SelectRestaurantsGlobalAsync(CityFragment? cityFilter, string? nameQuery = null, int limit = 20)
        {
            Console.WriteLine();
            Console.WriteLine("=== GLOBAL SELECT: Restoranų suvestinė (M1 MySQL + M2 Redis) ===");
            Console.WriteLine($"Maršrutizavimas: {(cityFilter.HasValue ? $"tik {cityFilter.Value} fragmentas" : "Scatter-Gather per Kaunas (H1) ir Vilnius (H2)")}");

            var rows = new List<(CityFragment City, M1RestaurantSummary M1, int InvCount, int InvQtySum, int ProdCount, string? RedisName)>();

            foreach (var target in _router.GetTargets(cityFilter))
            {
                // 1. M1 MySQL: aggregate employees & customer orders per restaurant
                var m1Map = new Dictionary<int, M1RestaurantSummary>();
                await using (var conn = new MySqlConnection(target.MySqlConnString))
                {
                    await conn.OpenAsync();
                    var sql = @"
                        SELECT r.restoranas_id, r.pavadinimas, r.vietove, r.telefonas,
                               (SELECT COUNT(*) FROM darbuotojas d WHERE d.restoranas_id = r.restoranas_id) AS emp_cnt,
                               (SELECT COUNT(*) FROM kliento_uzsakymas ku WHERE ku.restoranas_id = r.restoranas_id) AS ord_cnt,
                               (SELECT COALESCE(SUM(
                                    CASE WHEN ku.kaina > 0 THEN ku.kaina
                                         ELSE (SELECT COALESCE(SUM(ke.kaina), 0) FROM kliento_eilute ke WHERE ke.kliento_uzsakymas_id = ku.kliento_uzsakymas_id)
                                    END), 0)
                                FROM kliento_uzsakymas ku WHERE ku.restoranas_id = r.restoranas_id) AS rev
                        FROM restoranas r
                        WHERE (@q IS NULL OR r.pavadinimas LIKE CONCAT('%', @q, '%'))
                        ORDER BY r.restoranas_id;";
                    await using var cmd = new MySqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@q", string.IsNullOrWhiteSpace(nameQuery) ? DBNull.Value : nameQuery.Trim());
                    await using var reader = await cmd.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                    {
                        var item = new M1RestaurantSummary(
                            reader.GetInt32("restoranas_id"),
                            reader.GetString("pavadinimas"),
                            reader.GetString("vietove"),
                            reader.IsDBNull(reader.GetOrdinal("telefonas")) ? null : reader.GetString("telefonas"),
                            reader.GetInt32("emp_cnt"),
                            reader.GetInt32("ord_cnt"),
                            reader.GetDecimal("rev"));
                        m1Map[item.RestoranasId] = item;
                    }
                }

                if (m1Map.Count == 0)
                    continue;

                // 2. M2 Redis: RediSearch (FT.SEARCH) for restaurants, inventory, and products on this shard
                string ftQuery = "*";
                if (!string.IsNullOrWhiteSpace(nameQuery))
                {
                    string safe = RedisIndexService.EscapeSearchTerm(nameQuery);
                    if (!string.IsNullOrEmpty(safe))
                        ftQuery = $"@pavadinimas:*{safe}*";
                }

                var m2Restaurants = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxRestoranas, ftQuery, limit: 200);
                var m2Inventorius = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxInventorius, "*", limit: 500);
                var m2Produktai = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxProduktas, "*", limit: 500);

                var redisNameByRestId = new Dictionary<int, string>();
                foreach (var doc in m2Restaurants)
                {
                    if (doc.Fields.TryGetValue("restoranas_id", out var ridStr) && int.TryParse(ridStr, out int rid))
                    {
                        doc.Fields.TryGetValue("pavadinimas", out var rName);
                        redisNameByRestId[rid] = rName ?? "";
                    }
                }

                var invByRest = m2Inventorius
                    .Where(d => d.Fields.ContainsKey("restoranas_id"))
                    .GroupBy(d => int.Parse(d.Fields["restoranas_id"]))
                    .ToDictionary(
                        g => g.Key,
                        g => (Count: g.Count(), Qty: g.Sum(x => int.TryParse(x.Fields.GetValueOrDefault("kiekis"), out int q) ? q : 0)));

                var prodByRest = m2Produktai
                    .Where(d => d.Fields.ContainsKey("restoranas_id"))
                    .GroupBy(d => int.Parse(d.Fields["restoranas_id"]))
                    .ToDictionary(g => g.Key, g => g.Count());

                // 3. Application-side Join by (City, restoranas_id) within this horizontal fragment
                foreach (var m1 in m1Map.Values.OrderBy(x => x.RestoranasId))
                {
                    invByRest.TryGetValue(m1.RestoranasId, out var inv);
                    prodByRest.TryGetValue(m1.RestoranasId, out int prodCnt);
                    redisNameByRestId.TryGetValue(m1.RestoranasId, out var rName);
                    rows.Add((target.City, m1, inv.Count, inv.Qty, prodCnt, rName));
                }
            }

            Console.WriteLine($"Rasta restoranų: {rows.Count} (rodoma iki {limit})");
            Console.WriteLine($"{"(Miestas, ID)",-15} | {"Pavadinimas (M1/M2)",-26} | {"Darb.(M1)",-9} | {"Užs./Suma (M1)",-17} | {"Inv.poz./vnt (M2)",-18} | {"Prod.(M2)",-9}");
            Console.WriteLine(new string('-', 108));

            foreach (var (city, m1, invCnt, invQty, prodCnt, rName) in rows.Take(limit))
            {
                string compositeKey = $"({city}, {m1.RestoranasId})";
                string displayName = m1.Pavadinimas.Length > 26 ? m1.Pavadinimas[..23] + "..." : m1.Pavadinimas;
                string ordersInfo = $"{m1.OrderCount} / {m1.TotalRevenue:F2}€";
                string invInfo = $"{invCnt} / {invQty} vnt.";
                Console.WriteLine($"{compositeKey,-15} | {displayName,-26} | {m1.EmployeeCount,-9} | {ordersInfo,-17} | {invInfo,-18} | {prodCnt,-9}");
            }
        }

        /// <summary>
        /// SELECT 2: Fetches a customer order & its recipe lines from M1 (MySQL),
        /// then fetches all recipe ingredients & current warehouse stock from M2 (Redis)
        /// using RediSearch (FT.SEARCH) + Redis Pipelining (IBatch), joining on receptas_id.
        /// </summary>
        public async Task SelectOrderWithIngredientsAsync(CityFragment city, int? orderId = null)
        {
            var target = _router.GetTarget(city);
            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL SELECT: Kliento užsakymas (M1:{target.MySqlDatabaseName}) + Ingredientų likučiai (M2:{target.RedisEndpoint}) ===");

            var orderLines = new List<(int OrderId, long OrderNr, decimal OrderPrice, int RestId, string RestName,
                int LineQty, decimal LinePrice, string PortionSize, int RecipeId, string RecipeName, string? DietName)>();

            await using (var conn = new MySqlConnection(target.MySqlConnString))
            {
                await conn.OpenAsync();
                string sql = orderId.HasValue
                    ? @"SELECT ku.kliento_uzsakymas_id, ku.uzsakymo_nr,
                               CASE WHEN ku.kaina > 0 THEN ku.kaina
                                    ELSE (SELECT COALESCE(SUM(ke2.kaina), 0) FROM kliento_eilute ke2 WHERE ke2.kliento_uzsakymas_id = ku.kliento_uzsakymas_id)
                               END AS order_kaina,
                               r.restoranas_id, r.pavadinimas AS rest_pav,
                               ke.kiekis, ke.kaina AS line_kaina,
                               pd.dydis, rec.receptas_id, rec.pavadinimas AS rec_pav, d.pavadinimas AS dieta_pav
                        FROM kliento_uzsakymas ku
                        JOIN restoranas r ON r.restoranas_id = ku.restoranas_id
                        JOIN kliento_eilute ke ON ke.kliento_uzsakymas_id = ku.kliento_uzsakymas_id
                        JOIN porcija p ON p.porcija_id = ke.porcija_id
                        JOIN porcijos_dydis pd ON pd.porcijos_dydis_id = p.porcijos_dydis_id
                        JOIN receptas rec ON rec.receptas_id = p.receptas_id
                        LEFT JOIN dieta d ON d.dieta_id = rec.dieta_id
                        WHERE ku.kliento_uzsakymas_id = @oid;"
                    : @"SELECT ku.kliento_uzsakymas_id, ku.uzsakymo_nr,
                               CASE WHEN ku.kaina > 0 THEN ku.kaina
                                    ELSE (SELECT COALESCE(SUM(ke2.kaina), 0) FROM kliento_eilute ke2 WHERE ke2.kliento_uzsakymas_id = ku.kliento_uzsakymas_id)
                               END AS order_kaina,
                               r.restoranas_id, r.pavadinimas AS rest_pav,
                               ke.kiekis, ke.kaina AS line_kaina,
                               pd.dydis, rec.receptas_id, rec.pavadinimas AS rec_pav, d.pavadinimas AS dieta_pav
                        FROM kliento_uzsakymas ku
                        JOIN restoranas r ON r.restoranas_id = ku.restoranas_id
                        JOIN kliento_eilute ke ON ke.kliento_uzsakymas_id = ku.kliento_uzsakymas_id
                        JOIN porcija p ON p.porcija_id = ke.porcija_id
                        JOIN porcijos_dydis pd ON pd.porcijos_dydis_id = p.porcijos_dydis_id
                        JOIN receptas rec ON rec.receptas_id = p.receptas_id
                        LEFT JOIN dieta d ON d.dieta_id = rec.dieta_id
                        ORDER BY ku.kliento_uzsakymas_id DESC
                        LIMIT 5;";

                await using var cmd = new MySqlCommand(sql, conn);
                if (orderId.HasValue)
                    cmd.Parameters.AddWithValue("@oid", orderId.Value);

                await using var reader = await cmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    orderLines.Add((
                        reader.GetInt32("kliento_uzsakymas_id"),
                        reader.GetInt64("uzsakymo_nr"),
                        reader.GetDecimal("order_kaina"),
                        reader.GetInt32("restoranas_id"),
                        reader.GetString("rest_pav"),
                        reader.GetInt32("kiekis"),
                        reader.GetDecimal("line_kaina"),
                        reader.GetString("dydis"),
                        reader.GetInt32("receptas_id"),
                        reader.GetString("rec_pav"),
                        reader.IsDBNull(reader.GetOrdinal("dieta_pav")) ? null : reader.GetString("dieta_pav")));
                }
            }

            if (orderLines.Count == 0)
            {
                Console.WriteLine("Nerasta kliento užsakymo eilučių šiame fragmente.");
                return;
            }

            // Collect distinct receptas_id values and query M2 using RediSearch secondary index
            var recipeIds = orderLines.Select(x => x.RecipeId).Distinct().ToList();
            var usedProductsByRecipe = new Dictionary<int, List<RedisHashDoc>>();
            var productIds = new HashSet<int>();

            foreach (int recId in recipeIds)
            {
                var usedDocs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb,
                    RedisIndexService.IdxNaudojamasProduktas,
                    $"@receptas_id:[{recId} {recId}]",
                    limit: 50);
                usedProductsByRecipe[recId] = usedDocs;
                foreach (var doc in usedDocs)
                {
                    if (doc.Fields.TryGetValue("produktas_id", out var pidStr) && int.TryParse(pidStr, out int pid))
                        productIds.Add(pid);
                }
            }

            // Use Redis Pipelining (IBatch) to fetch all referenced produktas:{id} hashes in 1 round-trip
            var productMap = new Dictionary<int, Dictionary<string, string>>();
            if (productIds.Count > 0)
            {
                IBatch batch = target.RedisDb.CreateBatch();
                var tasks = new Dictionary<int, Task<HashEntry[]>>();
                foreach (int pid in productIds)
                {
                    tasks[pid] = batch.HashGetAllAsync($"produktas:{pid}");
                }
                batch.Execute();
                await Task.WhenAll(tasks.Values);

                foreach (var kv in tasks)
                {
                    var entries = await kv.Value;
                    if (entries.Length > 0)
                    {
                        productMap[kv.Key] = entries.ToDictionary(
                            e => e.Name.ToString(),
                            e => e.Value.ToString(),
                            StringComparer.OrdinalIgnoreCase);
                    }
                }
            }

            // Display unified M1 + M2 result
            foreach (var orderGroup in orderLines.GroupBy(x => x.OrderId))
            {
                var head = orderGroup.First();
                Console.WriteLine($"\nUžsakymas #{head.OrderId} (Nr: {head.OrderNr}, Bendra suma: {head.OrderPrice:F2}€) | Restoranas ({city}, {head.RestId}) {head.RestName}");
                foreach (var line in orderGroup)
                {
                    Console.WriteLine($"  • Patiekalas (M1): {line.RecipeName} [receptas_id={line.RecipeId}] | Porcija: {line.PortionSize} | Kiekis: {line.LineQty} | Dieta: {line.DietName ?? "standartinė"}");
                    if (!usedProductsByRecipe.TryGetValue(line.RecipeId, out var ings) || ings.Count == 0)
                    {
                        Console.WriteLine("      └─ M2 ingredientai: (nėra susietų įrašų naudojamas_produktas fragmente)");
                        continue;
                    }

                    foreach (var ing in ings)
                    {
                        int pid = int.Parse(ing.Fields["produktas_id"]);
                        decimal perPortion = decimal.Parse(ing.Fields["kiekis"], CultureInfo.InvariantCulture);
                        decimal needed = perPortion * line.LineQty;
                        if (productMap.TryGetValue(pid, out var prod))
                        {
                            string pName = prod.GetValueOrDefault("pavadinimas", "?");
                            decimal stock = decimal.Parse(prod.GetValueOrDefault("kiekis", "0"), CultureInfo.InvariantCulture);
                            string exp = prod.GetValueOrDefault("galiojimo_pabaiga", "?");
                            string status = stock >= needed ? "PAKANKA" : "TRŪKSTA";
                            Console.WriteLine($"      └─ M2 produktas:{pid} '{pName}': reikia {needed:F3}, sandėlyje {stock:F3} (galioja iki {exp}) [{status}]");
                        }
                        else
                        {
                            Console.WriteLine($"      └─ M2 produktas:{pid}: reikia {needed:F3} (nerastas šiame Redis mazge)");
                        }
                    }
                }
            }
        }

        /// <summary>
        /// SELECT 3: Full-text search on M2 inventory items using RediSearch (FT.SEARCH)
        /// across Kaunas & Vilnius, then joins owning restoranas_id with M1 MySQL restaurant & staff info.
        /// </summary>
        public async Task SearchInventoryFullTextAsync(CityFragment? cityFilter, string searchText)
        {
            string safe = RedisIndexService.EscapeSearchTerm(searchText);
            if (string.IsNullOrWhiteSpace(safe))
            {
                Console.WriteLine("Įveskite paieškos žodį (pvz., peilis, lėkštė, kepimo).");
                return;
            }

            Console.WriteLine();
            Console.WriteLine($"=== GLOBAL FULL-TEXT SELECT (RediSearch FT.SEARCH '{safe}' -> M1 MySQL Join) ===");

            string ftQuery = $"@pavadinimas:{safe}*";
            int totalFound = 0;

            foreach (var target in _router.GetTargets(cityFilter))
            {
                var docs = await RedisIndexService.SearchHashesAsync(
                    target.RedisDb, RedisIndexService.IdxInventorius, ftQuery, limit: 30);

                if (docs.Count == 0)
                    continue;

                var restIds = docs
                    .Where(d => d.Fields.TryGetValue("restoranas_id", out var r) && int.TryParse(r, out _))
                    .Select(d => int.Parse(d.Fields["restoranas_id"]))
                    .Distinct()
                    .ToList();

                var m1RestMap = new Dictionary<int, (string Name, string City, int StaffCount)>();
                if (restIds.Count > 0)
                {
                    await using var conn = new MySqlConnection(target.MySqlConnString);
                    await conn.OpenAsync();
                    string inClause = string.Join(",", restIds);
                    string sql = $@"
                        SELECT r.restoranas_id, r.pavadinimas, r.vietove,
                               (SELECT COUNT(*) FROM darbuotojas d WHERE d.restoranas_id = r.restoranas_id) AS staff_cnt
                        FROM restoranas r
                        WHERE r.restoranas_id IN ({inClause});";
                    await using var cmd = new MySqlCommand(sql, conn);
                    await using var reader = await cmd.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                    {
                        m1RestMap[reader.GetInt32("restoranas_id")] = (
                            reader.GetString("pavadinimas"),
                            reader.GetString("vietove"),
                            reader.GetInt32("staff_cnt"));
                    }
                }

                foreach (var doc in docs)
                {
                    totalFound++;
                    int invId = int.Parse(doc.Fields.GetValueOrDefault("inventorius_id", "0"));
                    string itemName = doc.Fields.GetValueOrDefault("pavadinimas", "?");
                    string qty = doc.Fields.GetValueOrDefault("kiekis", "0");
                    int rid = int.Parse(doc.Fields.GetValueOrDefault("restoranas_id", "0"));

                    if (m1RestMap.TryGetValue(rid, out var rest))
                    {
                        Console.WriteLine($"  [{target.City}] {doc.Key} '{itemName}' (kiekis: {qty}) -> M1 restoranas ({target.City}, {rid}) '{rest.Name}' (darbuotojų: {rest.StaffCount})");
                    }
                    else
                    {
                        Console.WriteLine($"  [{target.City}] {doc.Key} '{itemName}' (kiekis: {qty}) -> ({target.City}, restoranas_id={rid}) (M1 nerastas)");
                    }
                }
            }

            if (totalFound == 0)
                Console.WriteLine("Pagal pateiktą paieškos žodį inventoriaus įrašų nerasta.");
        }
    }
}
