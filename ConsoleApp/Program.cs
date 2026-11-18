using System;
using System.Text;
using System.Threading.Tasks;
using MySqlConnector;
using StackExchange.Redis;

namespace ConsoleApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.OutputEncoding = Encoding.UTF8;
            Console.InputEncoding = Encoding.UTF8;

            const string M1Kaunas = "restaurant_db_Kaunas";
            const string M1Vilnius = "restaurant_db_Vilnius";
            //port
            const string M2Kaunas = "127.0.0.1:6379";
            const string M2Vilnius = "127.0.0.1:6380";

            var connStringM1K = "Server=127.0.0.1;Port=3306;Database=" + M1Kaunas + ";User ID=root;Password=root;AllowPublicKeyRetrieval=True;";
            var connStringM1V = "Server=127.0.0.1;Port=3306;Database=" + M1Vilnius + ";User ID=root;Password=root;AllowPublicKeyRetrieval=True;";

            // connects to all 4 database fragments (2 M1 in MySql, 2 M2 in Redis)
            await using var router = await ShardRouter.ConnectAsync(connStringM1K, connStringM1V, M2Kaunas, M2Vilnius);
            Console.WriteLine("Connected to M1Kaunas");
            Console.WriteLine("Connected to M1Vilnius");
            Console.WriteLine("Connected to M2Kaunas");
            Console.WriteLine("Connected to M2Vilnius");

            // Connection smoke tests
            await TestConnectionsAsync(connStringM1K, connStringM1V, router.DbM2Kaunas, router.DbM2Vilnius);

            // Ensure RediSearch indexes exist on both M2 horizontal fragments
            await RedisIndexService.EnsureIndexesAsync(router);
            Console.WriteLine("RediSearch indexes verified on M2Kaunas and M2Vilnius.");
            Console.WriteLine();

            var queryService = new GlobalQueryService(router);
            var insertService = new GlobalInsertService(router);

            if (args.Length > 0 && args[0].Equals("--demo", StringComparison.OrdinalIgnoreCase))
            {
                await RunDemoAsync(queryService, insertService);
                return;
            }
            if (args.Length > 0 && args[0].Equals("--test-all", StringComparison.OrdinalIgnoreCase))
            {
                await RunTestAllAsync(router, queryService, insertService);
                return;
            }

            bool repeat = true;
            while (repeat)
            {
                PrintMenu();
                Console.Write("Pasirinkite operaciją: ");
                string? rawQuery = Console.ReadLine();
                if (rawQuery is null)
                    break;
                string query = rawQuery.Trim();

                try
                {
                    switch (query)
                    {
                        case "1":
                        case "select-restaurants":
                            {
                                Console.Write("Miestas (Kaunas / Vilnius / tusčia = abu): ");
                                string? cityIn = Console.ReadLine();
                                if (!TryParseOptionalCity(cityIn, out var cityFilter))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Pavadinimo filtras (nebūtina): ");
                                string? nameFilter = Console.ReadLine();
                                await queryService.SelectRestaurantsGlobalAsync(cityFilter, nameFilter);
                                break;
                            }
                        case "2":
                        case "select-order":
                            {
                                Console.Write("Miestas (Kaunas / Vilnius) [Kaunas]: ");
                                string? cityIn = Console.ReadLine();
                                CityFragment city;
                                if (string.IsNullOrWhiteSpace(cityIn))
                                {
                                    city = CityFragment.Kaunas;
                                }
                                else if (!ShardRouter.TryParseCity(cityIn, out city))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Užsakymo ID (> 0, nebūtina, tusčia = naujausi 5): ");
                                string? oidRaw = Console.ReadLine();
                                int? oid = null;
                                if (!string.IsNullOrWhiteSpace(oidRaw))
                                {
                                    if (!int.TryParse(oidRaw, out int parsedOid) || parsedOid <= 0)
                                    {
                                        Console.WriteLine("Klaida: užsakymo ID turi būti teigiamas sveikasis skaičius (> 0).");
                                        break;
                                    }
                                    oid = parsedOid;
                                }
                                await queryService.SelectOrderWithIngredientsAsync(city, oid);
                                break;
                            }
                        case "3":
                        case "search-inventory":
                            {
                                Console.Write("Miestas (Kaunas / Vilnius / tusčia = abu): ");
                                string? cityIn = Console.ReadLine();
                                if (!TryParseOptionalCity(cityIn, out var cityFilter))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Inventoriaus paieškos frazė (pvz. peilis, lėkštė): ");
                                string term = Console.ReadLine() ?? "";
                                await queryService.SearchInventoryFullTextAsync(cityFilter, term);
                                break;
                            }
                        case "4":
                        case "insert-restaurant":
                            {
                                Console.Write("Miestas (Kaunas / Vilnius): ");
                                string? cityIn = Console.ReadLine();
                                if (!ShardRouter.TryParseCity(cityIn, out var city))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Restorano pavadinimas: ");
                                string name = Console.ReadLine() ?? "";
                                Console.Write("Telefonas (nebūtina): ");
                                string? phone = Console.ReadLine();
                                Console.Write("Svetainė (nebūtina): ");
                                string? web = Console.ReadLine();
                                Console.Write("Pradinio inventoriaus pavadinimas (pvz. Kavos aparatas): ");
                                string invName = Console.ReadLine() ?? "";
                                Console.Write("Pradinio inventoriaus kiekis (> 0): ");
                                if (!int.TryParse(Console.ReadLine(), out int invQty) || invQty <= 0)
                                {
                                    Console.WriteLine("Klaida: inventoriaus kiekis turi būti teigiamas sveikasis skaičius (> 0).");
                                    break;
                                }
                                Console.Write("Imituoti M2 gedimą ir Saga kompensaciją? (y/N): ");
                                bool simFail = string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase);

                                await insertService.InsertRestaurantWithInventoryAsync(
                                    name, city, phone, web, invName, invQty, simulateM2Failure: simFail);
                                break;
                            }
                        case "5":
                        case "insert-order":
                            {
                                Console.Write("Miestas (Kaunas / Vilnius): ");
                                string? cityIn = Console.ReadLine();
                                if (!ShardRouter.TryParseCity(cityIn, out var city))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Restoranas ID (> 0): ");
                                if (!int.TryParse(Console.ReadLine(), out int restId) || restId <= 0)
                                {
                                    Console.WriteLine("Klaida: restoranas_id turi būti teigiamas sveikasis skaičius (> 0).");
                                    break;
                                }
                                if (!await router.RestaurantExistsInCityAsync(city, restId))
                                {
                                    Console.WriteLine($"Klaida: restoranas su restoranas_id={restId} neegzistuoja {city} fragmente.");
                                    break;
                                }
                                Console.Write("Porcija ID (> 0, pvz. Kaune 16, Vilniuje 8): ");
                                if (!int.TryParse(Console.ReadLine(), out int porcijaId) || porcijaId <= 0)
                                {
                                    Console.WriteLine("Klaida: porcija_id turi būti teigiamas sveikasis skaičius (> 0).");
                                    break;
                                }
                                if (!await router.PortionExistsInCityAsync(city, porcijaId))
                                {
                                    Console.WriteLine($"Klaida: porcija su porcija_id={porcijaId} neegzistuoja {city} fragmente.");
                                    break;
                                }
                                Console.Write("Porcijų kiekis (> 0): ");
                                if (!int.TryParse(Console.ReadLine(), out int qty) || qty <= 0)
                                {
                                    Console.WriteLine("Klaida: porcijų kiekis turi būti teigiamas sveikasis skaičius (> 0).");
                                    break;
                                }
                                Console.Write("Stalelio nr. (> 0, nebūtina): ");
                                string? tableRaw = Console.ReadLine();
                                int? table = null;
                                if (!string.IsNullOrWhiteSpace(tableRaw))
                                {
                                    if (!int.TryParse(tableRaw, out int parsedTable) || parsedTable <= 0)
                                    {
                                        Console.WriteLine("Klaida: stalelio nr. turi būti teigiamas sveikasis skaičius (> 0).");
                                        break;
                                    }
                                    table = parsedTable;
                                }
                                Console.Write("Telefonas (nebūtina): ");
                                string? phone = Console.ReadLine();
                                Console.Write("Imituoti M1 gedimą ir Lua atsargų atstatymą? (y/N): ");
                                bool simFail = string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase);

                                await insertService.InsertCustomerOrderWithStockDeductionAsync(
                                    city, restId, porcijaId, qty, tableNumber: table, phone: phone, simulateM1Failure: simFail);
                                break;
                            }
                        case "0":
                        case "Exit":
                        case "exit":
                            Console.WriteLine("Exiting");
                            repeat = false;
                            break;
                        default:
                            Console.WriteLine("Unrecognized Query");
                            break;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Operacijos klaida: {ex.Message}");
                }
                Console.WriteLine();
            }
        }

        private static bool TryParseOptionalCity(string? input, out CityFragment? cityFilter)
        {
            if (string.IsNullOrWhiteSpace(input))
            {
                cityFilter = null;
                return true;
            }
            if (ShardRouter.TryParseCity(input, out var city))
            {
                cityFilter = city;
                return true;
            }
            cityFilter = null;
            return false;
        }

        private static void PrintMenu()
        {
            Console.WriteLine("------------------------------------------------------------");
            Console.WriteLine("1 | select-restaurants  - Globalus SELECT: restoranų suvestinė (M1 + M2)");
            Console.WriteLine("2 | select-order        - Globalus SELECT: užsakymas (M1) + produktų likučiai (M2 Pipeline)");
            Console.WriteLine("3 | search-inventory    - Globalus SELECT: inventoriaus paieška (RediSearch FT.SEARCH + M1)");
            Console.WriteLine("4 | insert-restaurant   - Globalus INSERT: restoranas (M1) + inventorius (M2) su Saga/TTL");
            Console.WriteLine("5 | insert-order        - Globalus INSERT: kliento užsakymas (M1) + atsargų nurašymas (M2 Lua)");
            Console.WriteLine("0 | Exit                - Baigti darbą");
            Console.WriteLine("------------------------------------------------------------");
        }

        private static async Task TestConnectionsAsync(
            string connStringM1K, string connStringM1V, IDatabase dbM2Kaunas, IDatabase dbM2Vilnius)
        {
            await using (var connK = new MySqlConnection(connStringM1K))
            {
                await connK.OpenAsync();
                await using var cmd = new MySqlCommand("SELECT pavadinimas FROM dieta WHERE dieta_id = 1;", connK);
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                    Console.WriteLine($"M1K test dieta[1]: {reader.GetString("pavadinimas")}");
            }

            await using (var connV = new MySqlConnection(connStringM1V))
            {
                await connV.OpenAsync();
                await using var cmd = new MySqlCommand("SELECT pavadinimas FROM dieta WHERE dieta_id = 1;", connV);
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                    Console.WriteLine($"M1V test dieta[1]: {reader.GetString("pavadinimas")}");
            }

            RedisValue valM2K = await dbM2Kaunas.HashGetAsync("tiekejas:3", "vardas");
            Console.WriteLine($"M2K test tiekejas:3: {valM2K}");
            RedisValue valM2V = await dbM2Vilnius.HashGetAsync("tiekejas:3", "vardas");
            Console.WriteLine($"M2V test tiekejas:3: {valM2V}");
        }

        private static async Task RunDemoAsync(GlobalQueryService queryService, GlobalInsertService insertService)
        {
            await queryService.SelectRestaurantsGlobalAsync(null, null, limit: 6);
            await queryService.SelectOrderWithIngredientsAsync(CityFragment.Kaunas, 1);
            await queryService.SelectOrderWithIngredientsAsync(CityFragment.Vilnius, null);
            await queryService.SearchInventoryFullTextAsync(null, "peilis");
        }

        private static async Task RunTestAllAsync(
            ShardRouter router, GlobalQueryService queryService, GlobalInsertService insertService)
        {
            await RunDemoAsync(queryService, insertService);

            Console.WriteLine("\n=== TEST 1: INSERT Restoranas (imituotas M2 gedimas -> Saga kompensacija) ===");
            int? failedRest = await insertService.InsertRestaurantWithInventoryAsync(
                "Test Kompensacija", CityFragment.Vilnius, "+37069900000", null,
                "Test krosnis", 2, idempotencyKey: "test-comp-1", simulateM2Failure: true);
            Console.WriteLine($"Rezultatas (tikimasi null): {(failedRest?.ToString() ?? "null")}");

            Console.WriteLine("\n=== TEST 2: INSERT Restoranas (Vilnius) + Idempotency pakartojimas + Kaunas ID sutapimas (46) ===");
            int? createdRestId = await insertService.InsertRestaurantWithInventoryAsync(
                "Test Bistro Vilnius", CityFragment.Vilnius, "+37069911111", "https://testbistro.lt",
                "Test espreso aparatas", 3, idempotencyKey: "test-rest-ok-1", simulateM2Failure: false);
            Console.WriteLine($"Sukurtas (Vilnius, restoranas_id): ({CityFragment.Vilnius}, {createdRestId})");
            int? dupRestId = await insertService.InsertRestaurantWithInventoryAsync(
                "Test Bistro Vilnius", CityFragment.Vilnius, "+37069911111", "https://testbistro.lt",
                "Test espreso aparatas", 3, idempotencyKey: "test-rest-ok-1", simulateM2Failure: false);
            Console.WriteLine($"Pakartotinis kvietimas su tuo pačiu idempotency raktu (tikimasi null): {(dupRestId?.ToString() ?? "null")}");

            int? createdKaunasRestId = await insertService.InsertRestaurantWithInventoryAsync(
                "Test Bistro Kaunas", CityFragment.Kaunas, "+37069922222", null,
                "Test grilis", 2, idempotencyKey: "test-rest-kaunas-overlap", simulateM2Failure: false);
            Console.WriteLine($"Sukurtas (Kaunas, restoranas_id) – gali sutapti su Vilniaus ID: ({CityFragment.Kaunas}, {createdKaunasRestId})");

            await queryService.SelectRestaurantsGlobalAsync(CityFragment.Vilnius, "Test Bistro");
            await queryService.SelectRestaurantsGlobalAsync(CityFragment.Kaunas, "Test Bistro");
            await queryService.SearchInventoryFullTextAsync(CityFragment.Vilnius, "espreso");

            Console.WriteLine("\n=== TEST 3: INSERT Kliento užsakymas (imituotas M1 gedimas -> Lua kompensacija) ===");
            var kaunasTarget = router.GetTarget(CityFragment.Kaunas);
            var rec2Ingredients = await RedisIndexService.SearchHashesAsync(
                kaunasTarget.RedisDb, RedisIndexService.IdxNaudojamasProduktas, "@receptas_id:[2 2]", 20);
            var savedStocks = new System.Collections.Generic.Dictionary<string, RedisValue>();
            foreach (var ing in rec2Ingredients)
            {
                string pKey = $"produktas:{ing.Fields["produktas_id"]}";
                savedStocks[pKey] = await kaunasTarget.RedisDb.HashGetAsync(pKey, "kiekis");
            }
            var firstProdKey = savedStocks.Keys.Count > 0 ? System.Linq.Enumerable.First(savedStocks.Keys) : "produktas:1";
            var beforeFailStock = savedStocks.GetValueOrDefault(firstProdKey);
            int? failedOrderId = await insertService.InsertCustomerOrderWithStockDeductionAsync(
                CityFragment.Kaunas, 45, 16, 1, tableNumber: 5, idempotencyKey: "test-ord-comp-1", simulateM1Failure: true);
            var afterFailStock = await kaunasTarget.RedisDb.HashGetAsync(firstProdKey, "kiekis");
            Console.WriteLine($"Užsakymas (tikimasi null): {(failedOrderId?.ToString() ?? "null")} | {firstProdKey} kiekis prieš={beforeFailStock}, po kompensacijos={afterFailStock}");

            Console.WriteLine("\n=== TEST 4: INSERT Kliento užsakymas (sėkmingas M2 Lua nurašymas + M1 ACID) ===");
            int? createdOrderId = await insertService.InsertCustomerOrderWithStockDeductionAsync(
                CityFragment.Kaunas, 45, 16, 1, tableNumber: 7, idempotencyKey: "test-ord-ok-1", simulateM1Failure: false);
            if (createdOrderId.HasValue)
            {
                await queryService.SelectOrderWithIngredientsAsync(CityFragment.Kaunas, createdOrderId.Value);
            }

            // Cleanup test records so initial dataset remains clean
            Console.WriteLine("\n=== CLEANUP: Testinių įrašų išvalymas ===");
            if (createdRestId.HasValue)
            {
                var vTarget = router.GetTarget(CityFragment.Vilnius);
                await using (var conn = new MySqlConnection(vTarget.MySqlConnString))
                {
                    await conn.OpenAsync();
                    await using var cmd = new MySqlCommand("DELETE FROM restoranas WHERE restoranas_id = @id;", conn);
                    cmd.Parameters.AddWithValue("@id", createdRestId.Value);
                    await cmd.ExecuteNonQueryAsync();
                }
                var invDocs = await RedisIndexService.SearchHashesAsync(
                    vTarget.RedisDb, RedisIndexService.IdxInventorius, $"@restoranas_id:[{createdRestId.Value} {createdRestId.Value}]", 10);
                foreach (var d in invDocs)
                    await vTarget.RedisDb.KeyDeleteAsync(d.Key);
                await vTarget.RedisDb.KeyDeleteAsync($"restoranas:{createdRestId.Value}");
                await vTarget.RedisDb.KeyDeleteAsync("tx:idemp:rest:Vilnius:test-rest-ok-1");
            }
            if (createdKaunasRestId.HasValue)
            {
                await using (var conn = new MySqlConnection(kaunasTarget.MySqlConnString))
                {
                    await conn.OpenAsync();
                    await using var cmd = new MySqlCommand("DELETE FROM restoranas WHERE restoranas_id = @id;", conn);
                    cmd.Parameters.AddWithValue("@id", createdKaunasRestId.Value);
                    await cmd.ExecuteNonQueryAsync();
                }
                var invDocs = await RedisIndexService.SearchHashesAsync(
                    kaunasTarget.RedisDb, RedisIndexService.IdxInventorius, $"@restoranas_id:[{createdKaunasRestId.Value} {createdKaunasRestId.Value}]", 10);
                foreach (var d in invDocs)
                    await kaunasTarget.RedisDb.KeyDeleteAsync(d.Key);
                await kaunasTarget.RedisDb.KeyDeleteAsync($"restoranas:{createdKaunasRestId.Value}");
                await kaunasTarget.RedisDb.KeyDeleteAsync("tx:idemp:rest:Kaunas:test-rest-kaunas-overlap");
            }
            if (createdOrderId.HasValue)
            {
                await using (var conn = new MySqlConnection(kaunasTarget.MySqlConnString))
                {
                    await conn.OpenAsync();
                    await using var cmd = new MySqlCommand("DELETE FROM kliento_uzsakymas WHERE kliento_uzsakymas_id = @id;", conn);
                    cmd.Parameters.AddWithValue("@id", createdOrderId.Value);
                    await cmd.ExecuteNonQueryAsync();
                }
                foreach (var kv in savedStocks)
                    await kaunasTarget.RedisDb.HashSetAsync(kv.Key, "kiekis", kv.Value);
                await kaunasTarget.RedisDb.KeyDeleteAsync("tx:idemp:order:Kaunas:test-ord-ok-1");
            }
            Console.WriteLine("Testiniai įrašai išvalyti, duomenų bazės grąžintos į pradinę būseną.");
        }
    }
}
