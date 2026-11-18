using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MySqlConnector;
using StackExchange.Redis;

namespace ConsoleApp
{
    public enum CityFragment
    {
        Kaunas,
        Vilnius
    }

    public sealed record ShardTarget(
        CityFragment City,
        string MySqlConnString,
        string MySqlDatabaseName,
        IDatabase RedisDb,
        string RedisEndpoint);

    /// <summary>
    /// Routes vertical (M1 MySQL vs M2 Redis) and horizontal (Kaunas vs Vilnius)
    /// operations to the proper physical fragments and allocates city-scoped (vertically unique) IDs.
    /// </summary>
    public sealed class ShardRouter : IAsyncDisposable
    {
        public const string M1Kaunas = "restaurant_db_Kaunas";
        public const string M1Vilnius = "restaurant_db_Vilnius";
        public const string M2Kaunas = "127.0.0.1:6379";
        public const string M2Vilnius = "127.0.0.1:6380";

        public string ConnStringM1K { get; }
        public string ConnStringM1V { get; }

        public ConnectionMultiplexer RedisM2Kaunas { get; }
        public ConnectionMultiplexer RedisM2Vilnius { get; }
        public IDatabase DbM2Kaunas { get; }
        public IDatabase DbM2Vilnius { get; }

        private ShardRouter(
            string connStringM1K,
            string connStringM1V,
            ConnectionMultiplexer redisM2Kaunas,
            ConnectionMultiplexer redisM2Vilnius)
        {
            ConnStringM1K = connStringM1K;
            ConnStringM1V = connStringM1V;
            RedisM2Kaunas = redisM2Kaunas;
            RedisM2Vilnius = redisM2Vilnius;
            DbM2Kaunas = redisM2Kaunas.GetDatabase();
            DbM2Vilnius = redisM2Vilnius.GetDatabase();
        }

        public static async Task<ShardRouter> ConnectAsync(
            string connStringM1K,
            string connStringM1V,
            string m2KaunasEndpoint,
            string m2VilniusEndpoint)
        {
            var redisK = await ConnectionMultiplexer.ConnectAsync(m2KaunasEndpoint);
            var redisV = await ConnectionMultiplexer.ConnectAsync(m2VilniusEndpoint);

            // Verify MySQL connectivity eagerly on both horizontal fragments
            await using (var c1 = new MySqlConnection(connStringM1K))
                await c1.OpenAsync();
            await using (var c2 = new MySqlConnection(connStringM1V))
                await c2.OpenAsync();

            return new ShardRouter(connStringM1K, connStringM1V, redisK, redisV);
        }

        public static bool TryParseCity(string? input, out CityFragment city)
        {
            if (string.Equals(input?.Trim(), "Kaunas", StringComparison.OrdinalIgnoreCase))
            {
                city = CityFragment.Kaunas;
                return true;
            }
            if (string.Equals(input?.Trim(), "Vilnius", StringComparison.OrdinalIgnoreCase))
            {
                city = CityFragment.Vilnius;
                return true;
            }
            city = default;
            return false;
        }

        public ShardTarget GetTarget(CityFragment city) => city switch
        {
            CityFragment.Kaunas => new ShardTarget(CityFragment.Kaunas, ConnStringM1K, M1Kaunas, DbM2Kaunas, M2Kaunas),
            CityFragment.Vilnius => new ShardTarget(CityFragment.Vilnius, ConnStringM1V, M1Vilnius, DbM2Vilnius, M2Vilnius),
            _ => throw new ArgumentOutOfRangeException(nameof(city))
        };

        public IEnumerable<ShardTarget> GetTargets(CityFragment? cityFilter)
        {
            if (cityFilter.HasValue)
            {
                yield return GetTarget(cityFilter.Value);
            }
            else
            {
                yield return GetTarget(CityFragment.Kaunas);
                yield return GetTarget(CityFragment.Vilnius);
            }
        }

        /// <summary>
        /// Verifies whether a restaurant with the given restoranas_id exists in the specified city fragment.
        /// </summary>
        public async Task<bool> RestaurantExistsInCityAsync(CityFragment city, int restoranasId)
        {
            var target = GetTarget(city);
            await using var conn = new MySqlConnection(target.MySqlConnString);
            await conn.OpenAsync();
            await using var cmd = new MySqlCommand(
                "SELECT COUNT(1) FROM restoranas WHERE restoranas_id = @id;", conn);
            cmd.Parameters.AddWithValue("@id", restoranasId);
            return Convert.ToInt32(await cmd.ExecuteScalarAsync()) > 0;
        }

        /// <summary>
        /// Verifies whether a portion with the given porcija_id exists in the specified city fragment.
        /// </summary>
        public async Task<bool> PortionExistsInCityAsync(CityFragment city, int porcijaId)
        {
            var target = GetTarget(city);
            await using var conn = new MySqlConnection(target.MySqlConnString);
            await conn.OpenAsync();
            await using var cmd = new MySqlCommand(
                "SELECT COUNT(1) FROM porcija WHERE porcija_id = @id;", conn);
            cmd.Parameters.AddWithValue("@id", porcijaId);
            return Convert.ToInt32(await cmd.ExecuteScalarAsync()) > 0;
        }

        /// <summary>
        /// Allocates the next MySQL integer ID within a single city horizontal fragment (not globally unique across cities).
        /// </summary>
        public async Task<int> GetNextCityMySqlIdAsync(CityFragment city, string tableName, string idColumn)
        {
            var target = GetTarget(city);
            await using var conn = new MySqlConnection(target.MySqlConnString);
            await conn.OpenAsync();
            await using var cmd = new MySqlCommand(
                $"SELECT COALESCE(MAX(`{idColumn}`), 0) FROM `{tableName}`;", conn);
            int maxId = Convert.ToInt32(await cmd.ExecuteScalarAsync());
            return maxId + 1;
        }

        /// <summary>
        /// Allocates the next Redis integer ID within a single city horizontal fragment.
        /// </summary>
        public async Task<int> GetNextCityRedisIdAsync(CityFragment city, string indexName, string idField)
        {
            var target = GetTarget(city);
            int maxId = 0;
            var top = await RedisIndexService.SearchHashesAsync(
                target.RedisDb, indexName, "*", limit: 1, sortByField: idField, descending: true);
            if (top.Count > 0 &&
                top[0].Fields.TryGetValue(idField, out var raw) &&
                int.TryParse(raw, out int parsed))
            {
                maxId = parsed;
            }
            return maxId + 1;
        }

        /// <summary>
        /// Allocates a vertically unique restoranas_id across M1 and M2 within a single city horizontal fragment.
        /// Different cities (Kaunas vs Vilnius) may share the same restoranas_id.
        /// </summary>
        public async Task<int> GetNextCityRestaurantIdAsync(CityFragment city)
        {
            int m1Max = await GetNextCityMySqlIdAsync(city, "restoranas", "restoranas_id") - 1;
            int m2Max = await GetNextCityRedisIdAsync(city, RedisIndexService.IdxRestoranas, "restoranas_id") - 1;
            return Math.Max(m1Max, m2Max) + 1;
        }

        public async ValueTask DisposeAsync()
        {
            await RedisM2Kaunas.DisposeAsync();
            await RedisM2Vilnius.DisposeAsync();
        }
    }
}
