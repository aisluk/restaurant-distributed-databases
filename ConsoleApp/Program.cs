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
            var updateService = new GlobalUpdateService(router);
            var deleteService = new GlobalDeleteService(router);

            if (args.Length > 0 && args[0].Equals("--demo", StringComparison.OrdinalIgnoreCase))
            {
                await RunDemoAsync(queryService, insertService);
                return;
            }
            if (args.Length > 0 && args[0].Equals("--test-all", StringComparison.OrdinalIgnoreCase))
            {
                await RunTestAllAsync(router, queryService, insertService, updateService, deleteService);
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
                        case "6":
                        case "edit-restaurant":
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
                                var current = await updateService.GetRestaurantAsync(city, restId);
                                if (current is null)
                                {
                                    Console.WriteLine($"Klaida: restoranas su restoranas_id={restId} neegzistuoja {city} fragmente.");
                                    break;
                                }

                                Console.WriteLine($"Dabartiniai duomenys (vietove='{current.Vietove}' neredaguojama): pavadinimas='{current.Pavadinimas}', telefonas='{current.Telefonas ?? "-"}', svetaine='{current.Svetaine ?? "-"}'");
                                Console.Write($"Naujas pavadinimas [Enter = palikti '{current.Pavadinimas}']: ");
                                string? nameIn = Console.ReadLine();
                                string newName = string.IsNullOrWhiteSpace(nameIn) ? current.Pavadinimas : nameIn.Trim();

                                Console.Write($"Naujas telefonas [Enter = palikti '{current.Telefonas ?? "-"}', '-' = išvalyti]: ");
                                string? newPhone = ResolveOptionalEdit(Console.ReadLine(), current.Telefonas);

                                Console.Write($"Nauja svetainė [Enter = palikti '{current.Svetaine ?? "-"}', '-' = išvalyti]: ");
                                string? newWebsite = ResolveOptionalEdit(Console.ReadLine(), current.Svetaine);

                                Console.Write("Imituoti M2 gedimą ir Saga kompensaciją? (y/N): ");
                                bool simFail = string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase);

                                await updateService.UpdateRestaurantAsync(
                                    city, restId, newName, newPhone, newWebsite, simulateM2Failure: simFail);
                                break;
                            }
                        case "7":
                        case "edit-employee":
                            {
                                Console.Write("Dabartinis darbuotojo miestas (Kaunas / Vilnius): ");
                                string? srcCityIn = Console.ReadLine();
                                if (!ShardRouter.TryParseCity(srcCityIn, out var srcCity))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Darbuotojas ID (> 0): ");
                                if (!int.TryParse(Console.ReadLine(), out int empId) || empId <= 0)
                                {
                                    Console.WriteLine("Klaida: darbuotojas_id turi būti teigiamas sveikasis skaičius (> 0).");
                                    break;
                                }
                                var current = await updateService.GetEmployeeAsync(srcCity, empId);
                                if (current is null)
                                {
                                    Console.WriteLine($"Klaida: darbuotojas su darbuotojas_id={empId} neegzistuoja {srcCity} fragmente.");
                                    break;
                                }

                                Console.WriteLine($"Dabartiniai duomenys: vardas='{current.Vardas}', pavardė='{current.Pavarde}', pareiga='{current.Pareiga}', atostogauja={current.Atostogauja}, telefonas='{current.Telefonas}', el_pastas='{current.ElPastas}', restoranas=({srcCity}, {current.RestoranasId})");

                                Console.Write($"Naujas vardas [Enter = palikti '{current.Vardas}']: ");
                                string? vardasIn = Console.ReadLine();
                                string newVardas = string.IsNullOrWhiteSpace(vardasIn) ? current.Vardas : vardasIn.Trim();

                                Console.Write($"Nauja pavardė [Enter = palikti '{current.Pavarde}']: ");
                                string? pavardeIn = Console.ReadLine();
                                string newPavarde = string.IsNullOrWhiteSpace(pavardeIn) ? current.Pavarde : pavardeIn.Trim();

                                Console.Write($"Nauja pareiga [Enter = palikti '{current.Pareiga}']: ");
                                string? pareigaIn = Console.ReadLine();
                                string newPareiga = string.IsNullOrWhiteSpace(pareigaIn) ? current.Pareiga : pareigaIn.Trim();

                                Console.Write($"Atostogauja? (y/n) [Enter = palikti {(current.Atostogauja ? "y" : "n")}]: ");
                                string? atostIn = Console.ReadLine()?.Trim();
                                bool newAtost = current.Atostogauja;
                                if (!string.IsNullOrWhiteSpace(atostIn))
                                {
                                    if (atostIn.Equals("y", StringComparison.OrdinalIgnoreCase) || atostIn.Equals("true", StringComparison.OrdinalIgnoreCase))
                                        newAtost = true;
                                    else if (atostIn.Equals("n", StringComparison.OrdinalIgnoreCase) || atostIn.Equals("false", StringComparison.OrdinalIgnoreCase))
                                        newAtost = false;
                                    else
                                    {
                                        Console.WriteLine("Klaida: įveskite 'y' arba 'n'.");
                                        break;
                                    }
                                }

                                Console.Write($"Naujas telefonas [Enter = palikti '{current.Telefonas}']: ");
                                string? telIn = Console.ReadLine();
                                string newTel = string.IsNullOrWhiteSpace(telIn) ? current.Telefonas : telIn.Trim();

                                Console.Write($"Naujas el. paštas [Enter = palikti '{current.ElPastas}']: ");
                                string? emailIn = Console.ReadLine();
                                string newEmail = string.IsNullOrWhiteSpace(emailIn) ? current.ElPastas : emailIn.Trim();

                                Console.Write($"Naujas restorano miestas (Kaunas / Vilnius) [Enter = palikti '{srcCity}']: ");
                                string? dstCityIn = Console.ReadLine();
                                CityFragment dstCity = srcCity;
                                if (!string.IsNullOrWhiteSpace(dstCityIn) && !ShardRouter.TryParseCity(dstCityIn, out dstCity))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }

                                int newRestId;
                                if (dstCity != srcCity)
                                {
                                    Console.Write($"Naujas restoranas_id {dstCity} fragmente (> 0): ");
                                    if (!int.TryParse(Console.ReadLine(), out newRestId) || newRestId <= 0)
                                    {
                                        Console.WriteLine("Klaida: restoranas_id turi būti teigiamas sveikasis skaičius (> 0).");
                                        break;
                                    }
                                }
                                else
                                {
                                    Console.Write($"Naujas restoranas_id [Enter = palikti {current.RestoranasId}]: ");
                                    string? restIdIn = Console.ReadLine();
                                    newRestId = current.RestoranasId;
                                    if (!string.IsNullOrWhiteSpace(restIdIn))
                                    {
                                        if (!int.TryParse(restIdIn, out newRestId) || newRestId <= 0)
                                        {
                                            Console.WriteLine("Klaida: restoranas_id turi būti teigiamas sveikasis skaičius (> 0).");
                                            break;
                                        }
                                    }
                                }

                                bool simFail = false;
                                if (dstCity != srcCity)
                                {
                                    Console.Write("Imituoti pradinio M1 gedimą ir Saga kompensaciją? (y/N): ");
                                    simFail = string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase);
                                }

                                await updateService.UpdateEmployeeAsync(
                                    srcCity, empId, newVardas, newPavarde, newPareiga, newAtost, newTel, newEmail,
                                    dstCity, newRestId, simulateSourceDeleteFailure: simFail);
                                break;
                            }
                        case "8":
                        case "delete-restaurant":
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
                                Console.Write("Ar tikrai norite ištrinti restoraną ir visus jo našlaičiais likusius įrašus? (y/N): ");
                                if (!string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase))
                                {
                                    Console.WriteLine("Šalinimas atšauktas.");
                                    break;
                                }
                                Console.Write("Imituoti M1 gedimą ir M2 atstatymą? (y/N): ");
                                bool simFail = string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase);

                                await deleteService.DeleteRestaurantCascadeAsync(
                                    city, restId, simulateM1Failure: simFail);
                                break;
                            }
                        case "9":
                        case "delete-recipe":
                            {
                                Console.Write("Miestas (Kaunas / Vilnius): ");
                                string? cityIn = Console.ReadLine();
                                if (!ShardRouter.TryParseCity(cityIn, out var city))
                                {
                                    Console.WriteLine("Klaida: tokio miesto sistemoje nėra (galimi tik 'Kaunas' arba 'Vilnius').");
                                    break;
                                }
                                Console.Write("Receptas ID (> 0): ");
                                if (!int.TryParse(Console.ReadLine(), out int recId) || recId <= 0)
                                {
                                    Console.WriteLine("Klaida: receptas_id turi būti teigiamas sveikasis skaičius (> 0).");
                                    break;
                                }
                                Console.Write("Ar tikrai norite ištrinti receptą, jo porcijas ir naudojamus produktus? (y/N): ");
                                if (!string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase))
                                {
                                    Console.WriteLine("Šalinimas atšauktas.");
                                    break;
                                }
                                Console.Write("Imituoti M1 gedimą ir M2 atstatymą? (y/N): ");
                                bool simFail = string.Equals(Console.ReadLine()?.Trim(), "y", StringComparison.OrdinalIgnoreCase);

                                await deleteService.DeleteRecipeCascadeAsync(
                                    city, recId, simulateM1Failure: simFail);
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

        private static string? ResolveOptionalEdit(string? input, string? current)
        {
            if (string.IsNullOrWhiteSpace(input))
                return current;
            string trimmed = input.Trim();
            return trimmed == "-" ? null : trimmed;
        }

        private static void PrintMenu()
        {
            Console.WriteLine("------------------------------------------------------------");
            Console.WriteLine("1 | select-restaurants  - Globalus SELECT: restoranų suvestinė (M1 + M2)");
            Console.WriteLine("2 | select-order        - Globalus SELECT: užsakymas (M1) + produktų likučiai (M2 Pipeline)");
            Console.WriteLine("3 | search-inventory    - Globalus SELECT: inventoriaus paieška (RediSearch FT.SEARCH + M1)");
            Console.WriteLine("4 | insert-restaurant   - Globalus INSERT: restoranas (M1) + inventorius (M2) su Saga/TTL");
            Console.WriteLine("5 | insert-order        - Globalus INSERT: kliento užsakymas (M1) + atsargų nurašymas (M2 Lua)");
            Console.WriteLine("6 | edit-restaurant     - Globalus UPDATE: restorano redagavimas (M1 + M2) su Saga/TTL");
            Console.WriteLine("7 | edit-employee       - Globalus UPDATE: darbuotojo redagavimas / perkėlimas tarp Kaunas ir Vilnius");
            Console.WriteLine("8 | delete-restaurant   - Globalus DELETE: restorano ir našlaičių šalinimas (M1 + M2) su Saga/TTL");
            Console.WriteLine("9 | delete-recipe       - Globalus DELETE: recepto, porcijų ir naudojamų produktų šalinimas (M1 + M2)");
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
            ShardRouter router, GlobalQueryService queryService, GlobalInsertService insertService, GlobalUpdateService updateService, GlobalDeleteService deleteService)
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

            if (createdRestId.HasValue)
            {
                Console.WriteLine("\n=== TEST 5: UPDATE Restoranas (Vilnius: M2 gedimas -> Saga kompensacija, po to sėkmingas UPDATE) ===");
                bool compUpdateOk = await updateService.UpdateRestaurantAsync(
                    CityFragment.Vilnius, createdRestId.Value, "Neturi Išlikti", "+37060000000", null,
                    idempotencyKey: "test-rest-upd-fail-1", simulateM2Failure: true);
                var afterComp = await updateService.GetRestaurantAsync(CityFragment.Vilnius, createdRestId.Value);
                Console.WriteLine($"Po kompensacijos (tikimasi false / 'Test Bistro Vilnius'): ok={compUpdateOk}, pavadinimas='{afterComp?.Pavadinimas}'");

                bool updateOk = await updateService.UpdateRestaurantAsync(
                    CityFragment.Vilnius, createdRestId.Value, "Test Bistro Vilnius Atnaujintas", "+37069933333", null,
                    idempotencyKey: "test-rest-upd-ok-1", simulateM2Failure: false);
                var afterUpdate = await updateService.GetRestaurantAsync(CityFragment.Vilnius, createdRestId.Value);
                var vTarget = router.GetTarget(CityFragment.Vilnius);
                var redisName = await vTarget.RedisDb.HashGetAsync($"restoranas:{createdRestId.Value}", "pavadinimas");
                var redisWebExists = await vTarget.RedisDb.HashExistsAsync($"restoranas:{createdRestId.Value}", "svetaine");
                Console.WriteLine($"Po sėkmingo UPDATE: ok={updateOk}, M1='{afterUpdate?.Pavadinimas}', M2='{redisName}', svetaine išvalyta={!redisWebExists}");
                await vTarget.RedisDb.KeyDeleteAsync("tx:idemp:rest-upd:Vilnius:test-rest-upd-ok-1");
            }

            Console.WriteLine("\n=== TEST 6: UPDATE Darbuotojas (perkėlimas Kaunas -> Vilnius su Saga kompensacija ir grąžinimu) ===");
            var empBefore = await updateService.GetEmployeeAsync(CityFragment.Kaunas, 1);
            if (empBefore is not null)
            {
                int? failedMove = await updateService.UpdateEmployeeAsync(
                    CityFragment.Kaunas, 1, empBefore.Vardas, empBefore.Pavarde, empBefore.Pareiga,
                    empBefore.Atostogauja, empBefore.Telefonas, empBefore.ElPastas,
                    CityFragment.Vilnius, 46, idempotencyKey: "test-emp-move-fail-1", simulateSourceDeleteFailure: true);
                var stillInKaunas = await updateService.GetEmployeeAsync(CityFragment.Kaunas, 1);
                Console.WriteLine($"Po kompensacijos (tikimasi null ir išlikimo Kaune): moved={failedMove?.ToString() ?? "null"}, Kaunas={stillInKaunas is not null}");

                int? movedEmpId = await updateService.UpdateEmployeeAsync(
                    CityFragment.Kaunas, 1, empBefore.Vardas, empBefore.Pavarde, "Vyr. padavėjas",
                    empBefore.Atostogauja, empBefore.Telefonas, empBefore.ElPastas,
                    CityFragment.Vilnius, 46, idempotencyKey: "test-emp-move-ok-1", simulateSourceDeleteFailure: false);
                var inKaunasAfter = await updateService.GetEmployeeAsync(CityFragment.Kaunas, 1);
                var inVilniusAfter = movedEmpId.HasValue ? await updateService.GetEmployeeAsync(CityFragment.Vilnius, movedEmpId.Value) : null;
                Console.WriteLine($"Po perkėlimo į Vilnių: newId={movedEmpId}, Kaunas={inKaunasAfter is not null}, Vilnius={inVilniusAfter is not null} (restoranas_id={inVilniusAfter?.RestoranasId})");

                if (movedEmpId.HasValue)
                {
                    await updateService.UpdateEmployeeAsync(
                        CityFragment.Vilnius, movedEmpId.Value, empBefore.Vardas, empBefore.Pavarde, empBefore.Pareiga,
                        empBefore.Atostogauja, empBefore.Telefonas, empBefore.ElPastas,
                        CityFragment.Kaunas, empBefore.RestoranasId, idempotencyKey: "test-emp-move-back-1", simulateSourceDeleteFailure: false);
                }
                await kaunasTarget.RedisDb.KeyDeleteAsync("tx:idemp:emp-move:Kaunas:Vilnius:test-emp-move-ok-1");
                var vTargetCleanup = router.GetTarget(CityFragment.Vilnius);
                await vTargetCleanup.RedisDb.KeyDeleteAsync("tx:idemp:emp-move:Vilnius:Kaunas:test-emp-move-back-1");
            }

            if (createdRestId.HasValue)
            {
                Console.WriteLine("\n=== TEST 7: DELETE Restoranas (imituotas M1 gedimas -> M2 atstatymas, po to kaskadinis šalinimas) ===");
                bool compDelOk = await deleteService.DeleteRestaurantCascadeAsync(
                    CityFragment.Vilnius, createdRestId.Value, idempotencyKey: "test-rest-del-fail-1", simulateM1Failure: true);
                var vTargetDel = router.GetTarget(CityFragment.Vilnius);
                bool stillInRedis = await vTargetDel.RedisDb.KeyExistsAsync($"restoranas:{createdRestId.Value}");
                Console.WriteLine($"Po M2 kompensacijos (tikimasi false ir true): ok={compDelOk}, M2 egzistuoja={stillInRedis}");

                bool delOk = await deleteService.DeleteRestaurantCascadeAsync(
                    CityFragment.Vilnius, createdRestId.Value, idempotencyKey: "test-rest-del-ok-1", simulateM1Failure: false);
                bool goneInRedis = !await vTargetDel.RedisDb.KeyExistsAsync($"restoranas:{createdRestId.Value}");
                bool goneInMysql = !await router.RestaurantExistsInCityAsync(CityFragment.Vilnius, createdRestId.Value);
                Console.WriteLine($"Po kaskadinio šalinimo: ok={delOk}, M2 ištrinta={goneInRedis}, M1 ištrinta={goneInMysql}");
                await vTargetDel.RedisDb.KeyDeleteAsync("tx:idemp:rest-del:Vilnius:test-rest-del-ok-1");
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
