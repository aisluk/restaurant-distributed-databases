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

Interactive menu commands (`0`–`11`):
1. `select-restaurants` – global restaurant summary (`M1 + M2`)
2. `select-order` – customer order (`M1`) + ingredient stock (`M2` Pipeline)
3. `search-inventory` – full-text inventory search (`RediSearch FT.SEARCH` + `M1`)
4. `insert-restaurant` – insert restaurant (`M1`) + inventory (`M2`) with Saga/TTL
5. `insert-order` – insert customer order (`M1`) + atomic stock deduction (`M2` Lua)
6. `edit-restaurant` – update restaurant across `M1` and `M2` with Saga/TTL
7. `edit-employee` – update employee in place or migrate between `Kaunas` and `Vilnius`
8. `delete-restaurant` – cascading delete of restaurant and orphaned records (`M1 + M2`) with Saga/TTL
9. `delete-recipe` – cascading delete of recipe, portions, and used products (`M1 + M2`) with Saga/TTL
10. `verify-integrity` – distributed integrity verification across all 4 fragments
11. `benchmark` – `Stopwatch` performance measurements on test data
0. `Exit` – exit the application

Additional CLI flags for quick demonstration and automated testing:
* `dotnet run -- --demo` – executes the core global `SELECT` queries.
* `dotnet run -- --benchmark` – runs distributed integrity verification (`verify-integrity`) and performance measurements (`benchmark`).
* `dotnet run -- --test-all` – runs initial integrity verification, all `SELECT`, `INSERT`, `UPDATE`, and `DELETE` operations (including failure simulations and Saga compensations), cleans up test records, re-verifies integrity, and runs performance benchmarks.

## Implemented Operations & Coordination

### Global `SELECT` Operations ([GlobalQueryService.cs](ConsoleApp/GlobalQueryService.cs))
1. **`select-restaurants`** – joins M1 (`restoranas`, `darbuotojas`, `kliento_uzsakymas`) and M2 (`idx:restoranas`, `idx:inventorius`, `idx:produktas`) into a unified summary (single city or Scatter-Gather across both cities). Rejects unknown cities with an error.
2. **`select-order`** – fetches a customer order with dish lines from M1 and joins via `receptas_id` with M2 ingredients and current stock levels.
3. **`search-inventory`** – full-text search on M2 inventory (`RediSearch FT.SEARCH`) joined with M1 restaurant and employee data. Rejects unknown cities with an error.

### Global `INSERT` Operations ([GlobalInsertService.cs](ConsoleApp/GlobalInsertService.cs))
Because MySQL and Redis do not support a shared distributed ACID / 2PC transaction, application-level **Saga** coordination is implemented:
1. **`insert-restaurant`** – allocates a city-scoped, vertically unique `restoranas_id` across M1 and M2 within the target city shard (`vietove = Kaunas` or `Vilnius`, allowing identical IDs across different cities), checks a city-scoped **Idempotency key (TTL)** in Redis, executes a local MySQL ACID transaction (M1), and writes to Redis via `MULTI/EXEC` with **Retry** (M2). If M2 fails, a **compensating operation** (`DELETE` in M1) rolls back the restaurant record.
2. **`insert-order`** – routes using the explicit `(city, restoranas_id)` combination (disambiguating restaurants when IDs overlap across cities), validates positive input fields, checks a city-scoped **Idempotency key (TTL)**, atomically checks and deducts recipe ingredients via a **Redis Lua script** (M2), and inserts `kliento_uzsakymas` + `kliento_eilute` in MySQL (M1). If M1 fails, a **compensating Lua script** restores M2 product stock.

### Global `UPDATE` (Edit) Operations ([GlobalUpdateService.cs](ConsoleApp/GlobalUpdateService.cs))
1. **`edit-restaurant`** – updates an existing restaurant identified by `(city, restoranas_id)` across both vertical fragments (`M1.restoranas` and `M2.restoranas:{id}`) while keeping the horizontal sharding key (`vietove`) immutable:
   - Acquires a city-scoped Redis **Idempotency key (TTL)** (`tx:idemp:rest-upd:{city}:{key}`).
   - Reads a pre-update snapshot in M1 using `SELECT ... FOR UPDATE` and executes the MySQL `UPDATE` inside an ACID transaction.
   - Updates the M2 hash via Redis `MULTI/EXEC` with retry (up to 3 attempts), using `HSET` for present fields and `HDEL` when optional fields (`telefonas`, `svetaine`) are cleared.
   - If M2 fails after retries, executes a **compensating `UPDATE`** in M1 to restore the previous `pavadinimas`, `telefonas`, and `svetaine` values and removes the idempotency lock.
2. **`edit-employee`** – updates an employee (`darbuotojas`) in M1, supporting both same-shard edits and cross-shard horizontal moves (`Kaunas ↔ Vilnius`):
   - **Same-shard update (`sourceCity == targetCity`)**: validates that `targetRestoranasId` exists in the target shard and executes a local MySQL ACID `UPDATE` on `darbuotojas`.
   - **Cross-shard migration (`sourceCity != targetCity`)**: when moving an employee to a restaurant in the other city shard, coordinates a Saga across the two horizontal M1 databases:
     1. Acquires a Redis idempotency lock (`tx:idemp:emp-move:{source}:{target}:{key}`).
     2. Allocates a new city-scoped `darbuotojas_id` in the destination shard (`GetNextCityMySqlIdAsync`).
     3. Inserts the updated employee record into the destination M1 shard (ACID commit).
     4. Deletes the old record from the source M1 shard (ACID commit).
     5. If deletion from the source M1 shard fails, executes a **compensating `DELETE`** in the destination shard so the employee is never duplicated.

### Global `DELETE` Operations ([GlobalDeleteService.cs](ConsoleApp/GlobalDeleteService.cs))
Both delete operations remove the target entity and all directly or indirectly orphaned dependent records across M2 and M1 while preserving shared lookup/reference tables (`tiekejas`, `dieta`, `porcijos_dydis`), coordinated by a Saga with M2 pre-delete snapshot restoration:
1. **`delete-restaurant`** (`DeleteRestaurantCascadeAsync`) – deletes `(city, restoranas_id)` and all orphaned dependents within that city shard:
   - Acquires a city-scoped Redis **Idempotency key (TTL)** (`tx:idemp:rest-del:{city}:{key}`).
   - Discovers all M2 keys to delete via RediSearch: `restoranas:{id}`, `inventorius` (`@restoranas_id`), `produktas` (`@restoranas_id`), `naudojamas_produktas` referencing deleted products, `uzsakymo_eilute` referencing deleted inventory/products, and any `restorano_uzsakymas` that becomes orphaned (0 remaining lines). **`tiekejas` records are preserved.**
   - Captures a full in-memory **M2 snapshot** (`HGETALL`) of all affected keys, then deletes them atomically via Redis `MULTI/EXEC`.
   - Executes a local MySQL ACID transaction in M1 deleting `kliento_eilute`, `kliento_uzsakymas`, `darbuotojas`, any `receptas` + `porcija` that became completely orphaned across both M2 and M1, and `restoranas`. **`dieta` and `porcijos_dydis` are preserved.**
   - If the M1 step fails, restores all deleted M2 hashes from the snapshot in a Redis `MULTI/EXEC` transaction (**compensating action**).
2. **`delete-recipe`** (`DeleteRecipeCascadeAsync`) – deletes `(city, receptas_id)` and its directly orphaned dependents:
   - Acquires a Redis **Idempotency key (TTL)** (`tx:idemp:rec-del:{city}:{key}`).
   - Finds all `naudojamas_produktas` entries in M2 matching `@receptas_id:[id id]`, snapshots them, and deletes them via Redis `MULTI/EXEC` (**`produktas` records are preserved**).
   - In M1 (MySQL ACID transaction), deletes `kliento_eilute` referencing the recipe's portions, `porcija` rows for that recipe, and the `receptas` row (**`dieta` and `porcijos_dydis` are preserved**).
   - If M1 fails, restores all snapshot `naudojamas_produktas` hashes back to M2 via `MULTI/EXEC`.

### Redis-Specific Capabilities Used
1. **RediSearch (`FT.CREATE` / `FT.SEARCH`)** – secondary and full-text indexes over Redis hashes ([RedisIndexService.cs](ConsoleApp/RedisIndexService.cs)), avoiding `SCAN *`. Creating indexes polls `FT.INFO` until initial background indexing completes (`indexing == 0`).
2. **Server-side Atomic Lua Scripts (`ScriptEvaluateAsync`)** – multi-key stock validation, deduction, and compensating restoration in a single atomic execution.
3. **Redis TTL (`StringSetAsync(..., expiry, When.NotExists)`)** – expiring idempotency keys (`tx:idemp:*`).
4. **Redis Pipelining (`CreateBatch()`)** – batching multiple `produktas:{id}` hash lookups in a single network round-trip.

## Integrity Verification, Failure/Recovery & Performance Measurement ([DiagnosticsService.cs](ConsoleApp/DiagnosticsService.cs))

### 1. Distributed Integrity Verification (`verify-integrity`)
`VerifyIntegrityAsync()` inspects all 4 physical fragments (`M1-H1`, `M1-H2`, `M2-H1`, `M2-H2`) on the test dataset and verifies:
1. **Horizontal sharding predicate (`vietove`)**: every `restoranas` row in M1 and every `restoranas:{id}` hash in M2 matches the shard city (`Kaunas` in H1, `Vilnius` in H2).
2. **Vertical 1:1 consistency (`M1.restoranas` ↔ `M2.restoranas:{id}`)**: every restaurant ID exists in both M1 and M2 of the same city with identical `pavadinimas`.
3. **Cross-vertical & intra-M2 referential integrity**: every `inventorius` and `produktas` in M2 references an existing `restoranas_id` in M1 of the same shard; every `naudojamas_produktas` references an existing `produktas_id` in M2; every `uzsakymo_eilute` references an existing `restorano_uzsakymas` in M2. (Also reports informational statistics on `naudojamas_produktas` entries matching local-shard M1 recipes.)
4. **Domain constraints**: all `produktas` and `inventorius` stock quantities in M2 are `>= 0`, and all `kliento_eilute` rows in M1 have `kiekis > 0` and `kaina >= 0`.

Observed output before and after running `--test-all` on the imported test dataset (`45` Kaunas restaurants, `46` Vilnius restaurants):
```text
Fragmentas [Kaunas] (M1: restaurant_db_Kaunas, M2: 127.0.0.1:6379):
  • Horizontalus predikatas (vietove='Kaunas'): M1 pažeidimų=0, M2 pažeidimų=0 (tikrinta M1=45, M2=45)
  • Vertikalus 1:1 atitikimas (M1<->M2 restoranas): trūksta M2=0, trūksta M1=0, pavadinimų nesutapimų=0
  • Kryžminis nuorodinis vientisumas: inventorius->restoranas=0, produktas->restoranas=0, naudojamas_produktas->produktas(M2)=0, uzsakymo_eilute->restorano_uzsakymas=0
  • Receptų nuorodų statistika (informacinė): naudojamas_produktas susietų su šio fragmento M1 receptas=47/144
  • Domeno / kiekio apribojimai: neigiamų produktas kiekis=0, neigiamų inventorius kiekis=0, neteisingų kliento_eilute=0
  => Būsena [Kaunas]: GALIOJA (0 pažeidimų)

Fragmentas [Vilnius] (M1: restaurant_db_Vilnius, M2: 127.0.0.1:6380):
  • Horizontalus predikatas (vietove='Vilnius'): M1 pažeidimų=0, M2 pažeidimų=0 (tikrinta M1=46, M2=46)
  • Vertikalus 1:1 atitikimas (M1<->M2 restoranas): trūksta M2=0, trūksta M1=0, pavadinimų nesutapimų=0
  • Kryžminis nuorodinis vientisumas: inventorius->restoranas=0, produktas->restoranas=0, naudojamas_produktas->produktas(M2)=0, uzsakymo_eilute->restorano_uzsakymas=0
  • Receptų nuorodų statistika (informacinė): naudojamas_produktas susietų su šio fragmento M1 receptas=18/52
  • Domeno / kiekio apribojimai: neigiamų produktas kiekis=0, neigiamų inventorius kiekis=0, neteisingų kliento_eilute=0
  => Būsena [Vilnius]: GALIOJA (0 pažeidimų)

Vientisumo patikrinimas SĖKMINGAS: visi 4 fragmentai suderinti (0 pažeidimų).
```

### 2. Failure & Recovery Scenarios (Saga Compensations)
The application demonstrates deterministic failure injection and automatic recovery (compensating actions) for every distributed write type in `--test-all`:
- **Order `INSERT` M1 failure → Lua stock recovery (`TEST 3`)**: M2 atomically deducts recipe ingredients via Lua (`produktas:1`: `22.000` → `21.170`), M1 MySQL fails after retries (`simulateM1Failure: true`), and the compensating Lua script restores `produktas:1` back to `22` (`0` orphan orders in M1, exact stock preserved in M2).
- **Restaurant `INSERT` M2 failure (`TEST 1`)**: M1 commits `restoranas_id=92`, M2 fails after 3 retries, and Saga compensation deletes `restoranas_id=92` from M1.
- **Restaurant `UPDATE` M2 failure (`TEST 5`)**: M1 commits the updated name, M2 fails after 3 retries, and Saga compensation restores M1 back to `'Test Bistro Vilnius'`.
- **Cross-shard Employee move failure (`TEST 6`)**: Destination shard (`Vilnius`) inserts `darbuotojas_id=163`, source shard (`Kaunas`) delete fails, and Saga compensation deletes `darbuotojas_id=163` from `Vilnius` while keeping `darbuotojas_id=1` in `Kaunas`.
- **Cascading `DELETE` M1 failure (`TEST 7` & `TEST 8`)**: M2 deletes target keys via `MULTI/EXEC`, M1 fails, and Saga compensation restores all deleted M2 hashes from the pre-delete snapshot (`2` keys restored for restaurant delete, `1` key restored for recipe delete).

### 3. Performance Measurement (`benchmark`)
`RunPerformanceBenchmarkAsync()` uses `System.Diagnostics.Stopwatch` (with warm-up iterations and muted console I/O during timed loops) on the test dataset (`dotnet run -- --test-all`):

| Scenario | Iterations | Total (ms) | Avg (ms) | Min (ms) | Max (ms) |
|---|---|---|---|---|---|
| M2 Sequential `HGETALL` (15 keys) | 30 | 109.12 | 3.64 | 3.11 | 5.18 |
| M2 Pipelined `IBatch` `HGETALL` (15 keys) | 30 | 11.21 | 0.37 | 0.30 | 0.61 |
| M2 Full Key `SCAN` + `HGETALL` (`inventorius:*`, `restoranas_id=1`) | 30 | 854.30 | 28.48 | 26.91 | 30.73 |
| M2 RediSearch `FT.SEARCH` (`@restoranas_id:[1 1]`) | 30 | 10.56 | 0.35 | 0.27 | 0.67 |
| Global `SELECT` (Single-Shard: Kaunas, M1+M2) | 15 | 65.26 | 4.35 | 4.01 | 5.77 |
| Global `SELECT` (Scatter-Gather: Kaunas+Vilnius, M1+M2) | 15 | 113.29 | 7.55 | 6.71 | 8.56 |
| Distributed Saga `INSERT` Order (M2 Lua + M1 ACID) | 5 | 39.05 | 7.81 | 7.49 | 8.33 |
| Distributed Saga Failure + Lua Compensation Recovery | 5 | 787.58 | 157.52 | 150.15 | 164.48 |

Key observations from the benchmark:
- **Redis Pipelining (`IBatch`)** reduces 15 sequential network round-trips from **3.64 ms** to **0.37 ms** (~**9.8×** speedup).
- **RediSearch secondary index (`FT.SEARCH`)** reduces filtered inventory lookup from **28.48 ms** (`SCAN` + `HGETALL`) to **0.35 ms** (~**81×** speedup).
- **Single-Shard routing** (`4.35 ms`) avoids the extra shard hop of **Scatter-Gather** (`7.55 ms`).
- **Saga Failure + Compensation Recovery** takes **157.52 ms** on average because `GlobalInsertService` performs an intentional retry with `150 ms` backoff before executing the compensating Lua restoration script.

## Data accuracy and integrity

The data used in this distributed database is **machine generated** and **does not reflect** any real-life locations, events or people. Any real-life matches are a coincidence.

The purpose of this database and laboratory work is just to get familiar with database distributing and integrity managing in MySql and Redis, not ensure accuracy of the data used.
