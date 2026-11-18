using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using StackExchange.Redis;

namespace ConsoleApp
{
    public sealed record RedisHashDoc(string Key, Dictionary<string, string> Fields);

    /// <summary>
    /// Manages RediSearch (FT.CREATE / FT.SEARCH) secondary and full-text indexes
    /// on both Redis Stack horizontal shards so M2 queries avoid O(N) full key scans.
    /// </summary>
    public static class RedisIndexService
    {
        public const string IdxRestoranas = "idx:restoranas";
        public const string IdxInventorius = "idx:inventorius";
        public const string IdxProduktas = "idx:produktas";
        public const string IdxNaudojamasProduktas = "idx:naudojamas_produktas";

        public static async Task EnsureIndexesAsync(ShardRouter router)
        {
            foreach (var target in router.GetTargets(null))
            {
                await EnsureIndexAsync(target.RedisDb, IdxRestoranas, new object[]
                {
                    IdxRestoranas, "ON", "HASH", "PREFIX", "1", "restoranas:",
                    "SCHEMA",
                    "restoranas_id", "NUMERIC", "SORTABLE",
                    "pavadinimas", "TEXT",
                    "vietove", "TAG"
                });

                await EnsureIndexAsync(target.RedisDb, IdxInventorius, new object[]
                {
                    IdxInventorius, "ON", "HASH", "PREFIX", "1", "inventorius:",
                    "SCHEMA",
                    "inventorius_id", "NUMERIC", "SORTABLE",
                    "restoranas_id", "NUMERIC", "SORTABLE",
                    "pavadinimas", "TEXT",
                    "kiekis", "NUMERIC"
                });

                await EnsureIndexAsync(target.RedisDb, IdxProduktas, new object[]
                {
                    IdxProduktas, "ON", "HASH", "PREFIX", "1", "produktas:",
                    "SCHEMA",
                    "produktas_id", "NUMERIC", "SORTABLE",
                    "restoranas_id", "NUMERIC", "SORTABLE",
                    "pavadinimas", "TEXT",
                    "kiekis", "NUMERIC"
                });

                await EnsureIndexAsync(target.RedisDb, IdxNaudojamasProduktas, new object[]
                {
                    IdxNaudojamasProduktas, "ON", "HASH", "PREFIX", "1", "naudojamas_produktas:",
                    "SCHEMA",
                    "naudojamas_produktas_id", "NUMERIC", "SORTABLE",
                    "receptas_id", "NUMERIC", "SORTABLE",
                    "produktas_id", "NUMERIC", "SORTABLE"
                });
            }
        }

        /// <summary>
        /// Checks if index exists on both Redis fragments. if not, creates inverted/numeric indexes directly over Hash prefixes.
        /// </summary>
        /// <param name="db"></param>
        /// <param name="indexName"></param>
        /// <param name="createArgs"></param>
        /// <returns></returns>
        private static async Task EnsureIndexAsync(IDatabase db, string indexName, object[] createArgs)
        {
            try
            {
                await db.ExecuteAsync("FT.INFO", indexName);
            }
            catch (RedisServerException ex) when (ex.Message.Contains("Unknown index name", StringComparison.OrdinalIgnoreCase))
            {
                await db.ExecuteAsync("FT.CREATE", createArgs);
            }
        }

        /// <summary>
        /// Executes FT.SEARCH on a RediSearch index and parses the returned hash documents.
        /// </summary>
        public static async Task<List<RedisHashDoc>> SearchHashesAsync(
            IDatabase db,
            string indexName,
            string query,
            int limit = 100,
            string? sortByField = null,
            bool descending = false)
        {
            var args = new List<object> { indexName, query };
            if (!string.IsNullOrWhiteSpace(sortByField))
            {
                args.Add("SORTBY");
                args.Add(sortByField);
                args.Add(descending ? "DESC" : "ASC");
            }
            args.Add("LIMIT");
            args.Add("0");
            args.Add(limit.ToString());

            var result = await db.ExecuteAsync("FT.SEARCH", args.ToArray());
            var docs = new List<RedisHashDoc>();
            if (result.IsNull)
                return docs;

            // RESP3 (StackExchange.Redis 3.x default on Redis 7+): FT.SEARCH returns a Map with "results" array
            if (result.Resp3Type == ResultType.Map)
            {
                var rootMap = result.ToDictionary();
                if (!rootMap.TryGetValue("results", out var resultsVal) || resultsVal.IsNull)
                    return docs;

                foreach (var item in (RedisResult[])resultsVal!)
                {
                    var itemMap = item.ToDictionary();
                    string key = itemMap.TryGetValue("id", out var idVal) ? idVal.ToString()! : "";
                    var fields = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

                    if (itemMap.TryGetValue("extra_attributes", out var extraVal) && !extraVal.IsNull)
                    {
                        foreach (var kv in extraVal.ToDictionary())
                        {
                            fields[kv.Key] = kv.Value.ToString()!;
                        }
                    }
                    else if (itemMap.TryGetValue("values", out var valuesVal) && !valuesVal.IsNull)
                    {
                        var pairs = (RedisResult[])valuesVal!;
                        for (int j = 0; j + 1 < pairs.Length; j += 2)
                            fields[pairs[j].ToString()!] = pairs[j + 1].ToString()!;
                    }

                    docs.Add(new RedisHashDoc(key, fields));
                }
                return docs;
            }

            // RESP2 fallback: [totalCount, key1, [field1, val1, ...], key2, ...]
            var array = (RedisResult[])result!;
            if (array.Length <= 1)
                return docs;

            for (int i = 1; i + 1 < array.Length; i += 2)
            {
                string key = array[i].ToString()!;
                var fieldPairs = (RedisResult[])array[i + 1]!;
                var fields = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                for (int j = 0; j + 1 < fieldPairs.Length; j += 2)
                {
                    string fName = fieldPairs[j].ToString()!;
                    string fVal = fieldPairs[j + 1].ToString()!;
                    fields[fName] = fVal;
                }
                docs.Add(new RedisHashDoc(key, fields));
            }
            return docs;
        }

        public static string EscapeSearchTerm(string raw)
        {
            // Keep alphanumeric/Unicode letters & spaces, strip RediSearch syntax metacharacters
            var chars = new List<char>(raw.Length);
            foreach (char c in raw.Trim())
            {
                if (char.IsLetterOrDigit(c) || char.IsWhiteSpace(c))
                    chars.Add(c);
            }
            return new string(chars.ToArray()).Trim();
        }
    }
}
