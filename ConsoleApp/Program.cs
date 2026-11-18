using System;
using MySqlConnector;
using System.Threading.Tasks;
using StackExchange.Redis;


namespace ConsoleApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            const string M1Kaunas = "restaurant_db_Kaunas";
            const string M1Vilnius = "restaurant_db_Vilnius";
            //port
            const string M2Kaunas = "127.0.0.1:6379";
            const string M2Vilnius = "127.0.0.1:6380";


            var connStringM1K = "Server=127.0.0.1;Port=3306;Database=" + M1Kaunas + ";User ID=root;Password=root;AllowPublicKeyRetrieval=True;";
            var connStringM1V = "Server=127.0.0.1;Port=3306;Database=" + M1Vilnius + ";User ID=root;Password=root;AllowPublicKeyRetrieval=True;";
            

            await using var connectionM1K = new MySqlConnection(connStringM1K);
            await connectionM1K.OpenAsync();
            Console.WriteLine("Connected to M1Kaunas");

            await using var connectionM1V = new MySqlConnection(connStringM1V);
            await connectionM1V.OpenAsync();
            Console.WriteLine("Connected to M1Vilnius");

            await using var RedisM2Kaunas = await ConnectionMultiplexer.ConnectAsync(M2Kaunas);
            IDatabase DbM2Kaunas = RedisM2Kaunas.GetDatabase();
            Console.WriteLine("Connected to M2Kaunas");

            await using var RedisM2Vilnius = await ConnectionMultiplexer.ConnectAsync(M2Kaunas);
            IDatabase DbM2Vilnius = RedisM2Vilnius.GetDatabase();
            Console.WriteLine("Connected to M2Vilnius");


            //Testing connections
            await using var cmdM1K = new MySqlCommand("SELECT pavadinimas FROM dieta WHERE dieta_id = 1;", connectionM1K);
            await using var readerM1K = await cmdM1K.ExecuteReaderAsync();
            while (await readerM1K.ReadAsync())
            {
                string pavadinimas = readerM1K.GetString("pavadinimas");
                Console.WriteLine(pavadinimas);
            }
            await using var cmdM1V = new MySqlCommand("SELECT pavadinimas FROM dieta WHERE dieta_id = 1;", connectionM1V);
            await using var readerM1V = await cmdM1V.ExecuteReaderAsync();
            while (await readerM1V.ReadAsync())
            {
                string pavadinimas = readerM1V.GetString("pavadinimas");
                Console.WriteLine(pavadinimas);
            }

            RedisValue valM2K = await DbM2Kaunas.HashGetAsync("tiekejas:3", "vardas");
            Console.WriteLine(valM2K);
            RedisValue valM2V = await DbM2Vilnius.HashGetAsync("tiekejas:3", "vardas");
            Console.WriteLine(valM2K);

            Console.WriteLine();

            bool Repeat = true;
            while (Repeat)
            {
                Console.WriteLine("Write the querry");
                string querry = Console.ReadLine();
                switch (querry)
                {
                    case "Exit":
                        Console.WriteLine("Exiting");
                        Repeat = false;
                        break;
                    default:
                        Console.WriteLine("Unrecognized Querry");
                        break;
                }

            }
            

        }
    }
}