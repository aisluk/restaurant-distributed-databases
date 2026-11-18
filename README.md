# Restaurant Distributed Databases (MySQL 8.4 + Redis Stack)

Demonstration .NET 10 console application ([ConsoleApp](ConsoleApp)) working with a heterogeneous distributed database split vertically (**M1** MySQL, **M2** Redis Stack) and horizontally by city (**Kaunas**, **Vilnius**).

## Architecture & Fragmentation

| Fragment | DBMS / Endpoint | Database / Keys | Sharding Criterion |
|---|---|---|---|
| **M1-H1** | MySQL 8.4 (`127.0.0.1:3306`) | `restaurant_db_Kaunas` | `vietove = 'Kaunas'` (`restoranas_id` 1–45) |
| **M1-H2** | MySQL 8.4 (`127.0.0.1:3306`) | `restaurant_db_Vilnius` | `vietove = 'Vilnius'` (`restoranas_id` 46–91) |
| **M2-H1** | Redis Stack (`127.0.0.1:6379`) | `restoranas:*`, `inventorius:*`, `produktas:*`, `naudojamas_produktas:*`, `restorano_uzsakymas:*`, `uzsakymo_eilute:*`, `tiekejas:*` | `vietove = 'Kaunas'` |
| **M2-H2** | Redis Stack (`127.0.0.1:6380`) | same key prefixes | `vietove = 'Vilnius'` |

Newly inserted restaurants do not have globally unique IDs across cities — `restoranas_id` is vertically unique within each city fragment (M1-city ↔ M2-city), so Kaunas and Vilnius can share the same `restoranas_id` (e.g., `(Kaunas, 46)` and `(Vilnius, 46)`). All restaurant operations identify restaurants by the `(city, restoranas_id)` combination.

Links between vertical fragments are maintained via shared identifiers within each city fragment:
* `(city, restoranas_id)` (`M1.restoranas` ↔ `M2.restoranas:{id}`, `M2.inventorius`, `M2.produktas`)
* `receptas_id` (`M1.receptas` / `M1.porcija` ↔ `M2.naudojamas_produktas`)

## Setup & Launch Instructions (Docker + .NET)

### 1. Docker Containers
Ensure `mysql-lab` (`root` password `root`, port `3306`), `redis-stack` (`6379`), and `redis-stack-2` (`6380`) are running:

```powershell
docker start mysql-lab redis-stack redis-stack-2
```

If the containers do not exist yet or you want to re-import data from `ImportData/`:

```powershell
# MySQL 8.4 (if creating from scratch)
docker run -d --name mysql-lab -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:8.4

# Redis Stack (Kaunas and Vilnius)
docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 redis/redis-stack:latest
docker run -d --name redis-stack-2 -p 6380:6379 -p 8002:8001 redis/redis-stack:latest

# Import data (from the repository root directory)
Get-Content -Raw -Encoding UTF8 ImportData\M1_Kaunas_Data_And_ER.sql | docker exec -i -e MYSQL_PWD=root mysql-lab mysql -uroot --default-character-set=utf8mb4
Get-Content -Raw -Encoding UTF8 ImportData\M1_Vilnius_Data_And_ER.sql | docker exec -i -e MYSQL_PWD=root mysql-lab mysql -uroot --default-character-set=utf8mb4
docker exec redis-stack redis-cli FLUSHALL
Get-Content -Raw -Encoding UTF8 ImportData\M2_Kaunas.redis | docker exec -i redis-stack redis-cli
docker exec redis-stack-2 redis-cli FLUSHALL
Get-Content -Raw -Encoding UTF8 ImportData\M2_Vilnius.redis | docker exec -i redis-stack-2 redis-cli
```

If Redis or Docker doesn't yet exist on the system, download the necessary tools through their instructions here:
```
https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/install-redis-cli/
```
```
https://docs.docker.com/desktop/setup/install/windows-install/
```


### 2. Running the Application

```powershell
cd ConsoleApp
dotnet run
```

Additional CLI flags for quick demonstration and automated testing:
* `dotnet run -- --demo` – executes the core global `SELECT` queries.
* `dotnet run -- --test-all` – runs all `SELECT` and `INSERT` operations (including failure simulation and Saga compensations), then cleans up test records.

## Implemented Operations & Coordination

### Global `SELECT` Operations ([GlobalQueryService.cs](ConsoleApp/GlobalQueryService.cs))
1. **`select-restaurants`** – joins M1 (`restoranas`, `darbuotojas`, `kliento_uzsakymas`) and M2 (`idx:restoranas`, `idx:inventorius`, `idx:produktas`) into a unified summary (single city or Scatter-Gather across both cities). Rejects unknown cities with an error.
2. **`select-order`** – fetches a customer order with dish lines from M1 and joins via `receptas_id` with M2 ingredients and current stock levels.
3. **`search-inventory`** – full-text search on M2 inventory (`RediSearch FT.SEARCH`) joined with M1 restaurant and employee data. Rejects unknown cities with an error.

### Global `INSERT` Operations ([GlobalInsertService.cs](ConsoleApp/GlobalInsertService.cs))
Because MySQL and Redis do not support a shared distributed ACID / 2PC transaction, application-level **Saga** coordination is implemented:
1. **`insert-restaurant`** – allocates a city-scoped, vertically unique `restoranas_id` across M1 and M2 within the target city shard (`vietove = Kaunas` or `Vilnius`, allowing identical IDs across different cities), checks a city-scoped **Idempotency key (TTL)** in Redis, executes a local MySQL ACID transaction (M1), and writes to Redis via `MULTI/EXEC` with **Retry** (M2). If M2 fails, a **compensating operation** (`DELETE` in M1) rolls back the restaurant record.
2. **`insert-order`** – routes using the explicit `(city, restoranas_id)` combination (disambiguating restaurants when IDs overlap across cities), validates positive input fields, checks a city-scoped **Idempotency key (TTL)**, atomically checks and deducts recipe ingredients via a **Redis Lua script** (M2), and inserts `kliento_uzsakymas` + `kliento_eilute` in MySQL (M1). If M1 fails, a **compensating Lua script** restores M2 product stock.

### Redis-Specific Capabilities Used
1. **RediSearch (`FT.CREATE` / `FT.SEARCH`)** – secondary and full-text indexes over Redis hashes ([RedisIndexService.cs](ConsoleApp/RedisIndexService.cs)), avoiding `SCAN *`.
2. **Server-side Atomic Lua Scripts (`ScriptEvaluateAsync`)** – multi-key stock validation, deduction, and compensating restoration in a single atomic execution.
3. **Redis TTL (`StringSetAsync(..., expiry, When.NotExists)`)** – expiring idempotency keys (`tx:idemp:*`).
4. **Redis Pipelining (`CreateBatch()`)** – batching multiple `produktas:{id}` hash lookups in a single network round-trip.

## Data accuracy and integrity

The data used in this distributed database is **machine generated** and **does not reflect** any real-life locations, events or people. Any real-life matches are a coincidence. 

The purpose of this database and laboratory work is just to get familiar with database distributing and integrity managing in MySql and Redis, not ensure accuracy of the data used.