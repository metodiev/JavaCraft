-- V15 — SQL and PostgreSQL for Java engineers.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('sql-query-fundamentals', 'SQL Query Fundamentals', 'Filter, order, and combine rows while respecting NULL three-valued logic.', 'Junior', 24, true, 1),
    ('sql-joins-in-depth', 'SQL Joins in Depth', 'Choose the right join type and avoid accidental row multiplication.', 'Junior', 26, true, 1),
    ('sql-aggregations-and-window-functions', 'Aggregations and Window Functions', 'Group rows for totals and use window functions for ranking and running totals.', 'Mid', 30, true, 1),
    ('sql-indexing-strategy', 'SQL Indexing Strategy', 'Design B-tree and covering indexes that match real query shapes.', 'Mid', 32, true, 1),
    ('sql-query-planner-and-explain', 'The Query Planner and EXPLAIN', 'Read EXPLAIN ANALYZE output and find the plan nodes that actually cost time.', 'Mid', 30, true, 1),
    ('sql-transactions-and-locking', 'Transactions and Locking', 'Choose isolation levels and acquire row locks in a consistent order.', 'Mid', 34, true, 1),
    ('sql-constraints-and-integrity', 'Constraints and Data Integrity', 'Enforce invariants in the database with keys, checks, and NOT NULL.', 'Mid', 28, true, 1),
    ('sql-normalization-and-modeling', 'Normalization and Data Modeling', 'Normalize to third normal form first, then denormalize deliberately.', 'Junior', 30, true, 1),
    ('postgresql-jsonb-modeling', 'Modeling JSONB in PostgreSQL', 'Decide between jsonb documents and relational columns for flexible data.', 'Mid', 30, true, 1),
    ('postgresql-partitioning', 'Declarative Table Partitioning', 'Partition large tables by range and let pruning skip unused partitions.', 'Senior', 36, true, 1),
    ('postgresql-vacuum-and-bloat', 'Vacuum, Bloat, and Autovacuum', 'Understand dead tuples, tune autovacuum, and measure table bloat.', 'Senior', 34, true, 1),
    ('postgresql-connection-pooling', 'Connection Pooling in PostgreSQL', 'Treat database connections as scarce and size pools for the server.', 'Junior', 26, true, 1),
    ('postgresql-backup-and-recovery', 'Backup and Recovery', 'Choose logical or physical backups and rehearse restores before incidents.', 'Senior', 36, true, 1),
    ('postgresql-replication-basics', 'Streaming Replication Basics', 'Run a standby replica and reason about replication lag on read paths.', 'Mid', 32, true, 1),
    ('database-migrations-at-scale', 'Migrations at Scale', 'Apply the expand and contract pattern for zero-downtime schema changes.', 'Mid', 30, true, 1),
    ('postgresql-full-text-search', 'Full Text Search in PostgreSQL', 'Use tsvector, tsquery, and GIN indexes for in-database search.', 'Mid', 34, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('sql-query-fundamentals', 1, 'Filter rows with explicit predicates', $body$A query is a pipeline: FROM produces rows, WHERE removes them, SELECT projects columns, ORDER BY sorts, and LIMIT truncates last. Filtering early keeps later stages cheap and output small. In production the expensive mistake is comparing against NULL with `=` or `<>`, which evaluates to unknown and silently returns no rows, so a query whose filter column is nullable looks empty instead of broken. Always use `IS NULL` and `IS NOT NULL` for null tests. Rule of thumb: never write a negation with a nullable column without deciding what NULL should mean there.$body$, $code$SELECT id, email
FROM app_user
WHERE deleted_at IS NULL
  AND email IS NOT NULL
ORDER BY created_at DESC
LIMIT 20;$code$),
    ('sql-query-fundamentals', 2, 'NULL means unknown, not empty', $body$SQL uses three-valued logic: every predicate evaluates to true, false, or unknown, and WHERE keeps only true. So negating a comparison on a nullable column also drops rows whose value is NULL, and an aggregate such as `AVG` ignores NULLs entirely, which changes the denominator. `COUNT(*)` counts rows while `COUNT(column)` counts non-null values, so the two numbers differ exactly where data is missing. Treat NULL as missing information in the schema and in queries. Rule of thumb: give columns a NOT NULL constraint unless missing data is a genuine domain state.$body$, $code$SELECT status,
       count(*) AS rows,
       count(shipped_at) AS shipped
FROM orders
WHERE status <> 'CANCELLED'
GROUP BY status;$code$),
    ('sql-query-fundamentals', 3, 'Ordering is a property of the query', $body$Relational tables have no inherent order, so a result set is unordered unless the query says otherwise. Add a tiebreaker column to make ordering deterministic, especially with LIMIT, or paging results can repeat and skip rows. In PostgreSQL NULLs sort last in ascending order and can be positioned with `NULLS FIRST` or `NULLS LAST`. Collation also affects text comparison, so behavior can differ between environments. Rule of thumb: every query that pages or feeds a UI needs a stable ORDER BY with a unique tiebreaker such as the primary key.$body$, $code$SELECT id, total_cents
FROM orders
WHERE status = 'PAID'
ORDER BY created_at DESC, id DESC
LIMIT 50;$code$),
    ('sql-joins-in-depth', 1, 'Inner and outer joins', $body$An inner join keeps only matching pairs, so a customer with no orders disappears. A left join keeps every left row and fills unmatched right columns with NULL, which makes it the tool for optional relationships. Right and full joins are symmetric variants that are rarely needed and harder to read; prefer reordering a left join. The common production bug is filtering on the right table in WHERE, which silently discards the NULL-extended rows and turns the outer join back into an inner one. Rule of thumb: for an outer join, put right-table predicates in the ON clause and keep only left-table conditions in WHERE.$body$, $code$SELECT c.id, o.id AS order_id
FROM customer c
LEFT JOIN orders o
       ON o.customer_id = c.id
      AND o.status = 'PAID';$code$),
    ('sql-joins-in-depth', 2, 'Beware accidental fan-out', $body$Joining a one-to-many relationship multiplies parent rows, so a customer with forty orders appears forty times. Chaining joins then multiplies again, and aggregate functions land on the wrong grain, producing totals that look plausible and are wrong. Subqueries and lateral joins let you aggregate first and join the reduced result. The filter is the same shape: `EXISTS` answers whether a match exists without duplicating rows, and a scalar subquery returns exactly one value per row. Rule of thumb: verify grain after each join and aggregate at the finest level only when you truly need it.$body$, $code$SELECT c.email, totals.order_count
FROM customer c
JOIN LATERAL (
    SELECT count(*) AS order_count
    FROM orders o
    WHERE o.customer_id = c.id
) totals ON true;$code$),
    ('sql-joins-in-depth', 3, 'Choosing between join and subquery', $body$The planner usually flattens subqueries and semi-joins into the same plan shape, so readability decides. A correlated subquery can be slow when it runs per row, but `EXISTS` typically becomes an anti-join or semi-join that both returns early and preserves cardinality. Uncached NOT IN with a nullable subquery result is a classic trap: if the subquery returns any NULL, NOT IN yields no rows at all. Use NOT EXISTS for exclusion logic. Rule of thumb: use EXISTS to test relationships and joins when you need columns from both sides.$body$, $code$SELECT c.id
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
);$code$),
    ('sql-aggregations-and-window-functions', 1, 'GROUP BY collapses rows', $body$GROUP BY reduces many rows to one per group, so only grouping keys and aggregates can be selected; everything else must be aggregated or the query is rejected. Counting relationships is a common use, and `count(*)` inside a group counts rows in that group. HAVING filters groups after aggregation, while WHERE filters rows before it, and pushing conditions into WHERE reduces the work the aggregate must do. Rule of thumb: aggregate at the grain you mean, and check the group key list before trusting any total.$body$, $code$SELECT customer_id,
       count(*) AS order_count,
       sum(total_cents) AS revenue_cents
FROM orders
WHERE status = 'PAID'
GROUP BY customer_id
HAVING sum(total_cents) > 100000;$code$),
    ('sql-aggregations-and-window-functions', 2, 'Windows keep every row', $body$A window function computes across a set of related rows without collapsing them, so each row keeps its identity and gains a value such as a rank, an average, or a running total. The OVER clause defines the partition and the ordering, and a frame clause controls which rows are visible, with `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` giving a running total. Ranking functions differ: `row_number` is unique, `rank` leaves gaps for ties, and `dense_rank` does not. Rule of thumb: use a window when you would otherwise self-join to compare a row with its neighbors.$body$, $code$SELECT id,
       customer_id,
       sum(total_cents) OVER (
           PARTITION BY customer_id
           ORDER BY created_at
       ) AS running_total
FROM orders;$code$),
    ('sql-aggregations-and-window-functions', 3, 'Window frames change answers', $body$When a window has an ORDER BY, the default frame ends at the current row, so aggregates accumulate instead of covering the partition. That default surprises engineers who expect a partition-wide total and get a growing one. Fix it by writing an explicit frame or by omitting ORDER BY for partition-wide aggregates. Window functions also execute after WHERE and GROUP BY, which is why filtering on a window result requires a subquery or a common table expression. Rule of thumb: state the frame explicitly whenever the result must be a total rather than a running value.$body$, $code$SELECT id, total_cents,
       avg(total_cents) OVER (
           PARTITION BY customer_id
       ) AS customer_avg
FROM orders
ORDER BY customer_id, id;$code$),
    ('sql-indexing-strategy', 1, 'B-tree indexes answer shapes', $body$A B-tree index stores keys in sorted order, so it serves equality, ranges, and sorted output for the leading columns. PostgreSQL can read the index and skip the heap for covered columns, and `CREATE INDEX CONCURRENTLY` builds without blocking writes. The limitation is prefix shape: an index on `(a, b)` helps `a` and `a, b` but not `b` alone, and wrapping the indexed column in a function prevents a plain index from being used. Rule of thumb: model the index on the exact WHERE and ORDER BY shape the query uses.$body$, $code$CREATE INDEX CONCURRENTLY idx_orders_customer_created
    ON orders (customer_id, created_at DESC);

CREATE INDEX CONCURRENTLY idx_orders_status_created
    ON orders (status, created_at DESC);

CREATE INDEX CONCURRENTLY idx_orders_created
    ON orders (created_at DESC);$code$),
    ('sql-indexing-strategy', 2, 'Composite order and covering', $body$Column order in a composite index follows the query, not intuition: equality columns first, then the range or sort column, because a range stops further index navigation. A covering index adds the projected columns with INCLUDE so the plan avoids visiting the table entirely, which helps wide, hot read paths. Covering indexes are wider and therefore cost more to maintain, and an index on a low-selectivity column such as a boolean flag is rarely worth its write cost. Rule of thumb: every index must justify itself with a query and its write overhead.$body$, $code$CREATE INDEX idx_orders_lookup
    ON orders (customer_id, status)
    INCLUDE (total_cents, created_at);

CREATE INDEX idx_orders_paid_created
    ON orders (created_at DESC)
    WHERE status = 'PAID';$code$),
    ('sql-indexing-strategy', 3, 'Indexes make writes more expensive', $body$Every INSERT, UPDATE, and DELETE maintains each index on the table, so many indexes slow the write path and grow the WAL and cache footprint. Unused indexes are pure cost, and `pg_stat_user_indexes` exposes usage through `idx_scan` so you can find candidates for removal. Partial indexes help when queries always filter the same way, and expression indexes help when queries wrap a column in a function, but both require queries shaped to match. Rule of thumb: index deliberately from observed query patterns, and delete indexes that nothing uses.$body$, $code$SELECT indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE relname = 'orders'
ORDER BY idx_scan;

SELECT relname, n_tup_ins, n_tup_upd, n_tup_del
FROM pg_stat_user_tables
WHERE relname = 'orders';$code$),
    ('sql-query-planner-and-explain', 1, 'Reading EXPLAIN output', $body$EXPLAIN shows the plan tree chosen by the cost-based planner, with an estimated cost and row count per node. Costs are arbitrary units derived largely from page fetches, not milliseconds, so compare nodes rather than absolute numbers. Read the tree from the innermost node outward, and match the node type to the job: sequential scan reads the whole table, index scan reads selected rows, nested loop probes the inner input per outer row, and hash join builds a hash table once. Rule of thumb: look for the node where estimated rows diverge most from reality.$body$, $code$EXPLAIN
SELECT id
FROM orders
WHERE customer_id = 42
  AND created_at >= now() - interval '7 days';$code$),
    ('sql-query-planner-and-explain', 2, 'ANALYZE shows actual execution', $body$EXPLAIN ANALYZE runs the statement and reports actual rows and actual time per node, which turns estimation errors into visible facts. Actual rows far below the estimate at a node usually means stale statistics or correlated columns, and running ANALYZE refreshes the histogram. A sequential scan is not automatically bad: for a query that returns a large fraction of a small table it is the cheapest plan. Rule of thumb: use `EXPLAIN (ANALYZE, BUFFERS)` and read rows first, time second.$body$, $code$EXPLAIN (ANALYZE, BUFFERS)
SELECT id, total_cents
FROM orders
WHERE status = 'PENDING'
ORDER BY created_at DESC
LIMIT 50;$code$),
    ('sql-query-planner-and-explain', 3, 'Cost estimates are statistics-driven', $body$The planner estimates selectivity from column statistics collected by ANALYZE, so a table with stale statistics gets bad row estimates and a bad plan. Default statistics targets are fine for evenly distributed columns but too coarse for skewed ones, where `ALTER COLUMN SET STATISTICS` raises the sample size. Extended statistics tell the planner that columns are correlated so an equality on both is estimated correctly. Rule of thumb: investigate a bad plan by checking estimated versus actual rows, then fix statistics before rewriting the query.$body$, $code$ALTER TABLE orders
    ALTER COLUMN customer_id SET STATISTICS 500;

ALTER TABLE orders
    ALTER COLUMN status SET STATISTICS 500;

ANALYZE orders;$code$),
    ('sql-transactions-and-locking', 1, 'ACID in PostgreSQL', $body$A transaction groups statements that either all apply or none do. Atomicity and durability come from write-ahead logging: changes are written to WAL before data pages and replayed after a crash. Consistency is enforced by constraints, while isolation is implemented with multiversion concurrency control, so readers and writers do not block each other by default. The default level is read committed, where each statement sees a snapshot taken when it begins. Rule of thumb: keep transactions short so they hold locks and snapshots briefly.$body$, $code$BEGIN;
UPDATE account SET balance = balance - 100 WHERE id = 1;
UPDATE account SET balance = balance + 100 WHERE id = 2;
INSERT INTO account_transfer (from_id, to_id, amount_cents)
VALUES (1, 2, 100);
COMMIT;$code$),
    ('sql-transactions-and-locking', 2, 'Isolation levels and anomalies', $body$Read committed can see a row change between two statements, so a check-then-act sequence can race. Repeatable read takes one snapshot for the whole transaction and rejects or retries conflicting updates, while serializable adds predicate locking that can abort transactions with a serialization failure. PostgreSQL implements read uncommitted as read committed, so requesting it buys nothing beyond documented behavior. Applications must be written to retry serialization failures rather than treat them as bugs. Rule of thumb: raise isolation only for the specific operations that need it, and make the retry explicit.$body$, $code$BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM account WHERE id = 1 FOR UPDATE;
UPDATE account SET balance = balance - 100 WHERE id = 1;
UPDATE account SET balance = balance + 100 WHERE id = 2;
COMMIT;$code$),
    ('sql-transactions-and-locking', 3, 'Lock ordering prevents deadlocks', $body$Row locks taken by UPDATE are held until the transaction ends, and two transactions that lock the same rows in opposite order deadlock; PostgreSQL detects this and aborts one with a deadlock_detected error. Avoidance is structural: touch rows in a deterministic order, keep transactions short, and use `SELECT ... FOR UPDATE` when a read must precede a write. Beware of blocking too much with locks taken before user interaction or network calls. Rule of thumb: a transaction should acquire its locks in the same order every time and hold them for milliseconds.$body$, $code$BEGIN;
SELECT id FROM account
WHERE id IN (1, 2)
ORDER BY id
FOR UPDATE;
UPDATE account SET balance = balance - 100 WHERE id = 1;
COMMIT;$code$),
    ('sql-constraints-and-integrity', 1, 'Keys define identity', $body$A primary key declares the row identity and creates a unique B-tree index, so every row is addressable and duplicates are impossible. A unique constraint does the same for alternate natural keys such as an email address. Foreign keys keep references valid by rejecting inserts that point at missing rows, with options such as ON DELETE CASCADE or RESTRICT controlling what happens when the parent disappears. In PostgreSQL indexes on foreign key columns are not created automatically, which turns parent deletes into slow scans. Rule of thumb: index every foreign key column used for joins and cascades.$body$, $code$CREATE TABLE order_item (
    id bigserial PRIMARY KEY,
    order_id bigint NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    sku text NOT NULL,
    quantity integer NOT NULL CHECK (quantity > 0)
);

CREATE INDEX ON order_item (order_id);$code$),
    ('sql-constraints-and-integrity', 2, 'CHECK and NOT NULL as design tools', $body$A CHECK constraint states an invariant the database enforces on every writer, including migrations and ad hoc scripts, which no application-layer validation can guarantee. NOT NULL is the strongest cheap invariant: it removes three-valued logic from that column and lets queries compare directly. Add constraints with NOT VALID to skip a full table scan at creation and then validate in the background. Prefer constraints over triggers because they are declarative and visible to the planner. Rule of thumb: if a rule must always hold, put it in the schema, not only in the service.$body$, $code$ALTER TABLE orders
    ADD CONSTRAINT orders_total_positive
    CHECK (total_cents >= 0) NOT VALID;

ALTER TABLE orders
    VALIDATE CONSTRAINT orders_total_positive;$code$),
    ('sql-constraints-and-integrity', 3, 'Design-level NOT NULL discipline', $body$Deciding where NULL is allowed is a modeling decision, not a detail. Every nullable column doubles the states every query must consider and invites bugs when code forgets the null branch. Prefer NOT NULL with a default, an explicit sentinel, or a separate table for optional attributes. Beware of using NULL to mean two different things, such as unknown and not applicable, because queries cannot distinguish them. Rule of thumb: start every column NOT NULL and remove the constraint only with a written reason.$body$, $code$ALTER TABLE customer
    ADD COLUMN marketing_opt_in boolean NOT NULL DEFAULT false;

ALTER TABLE customer
    ADD COLUMN locale text NOT NULL DEFAULT 'en';

ALTER TABLE customer
    ADD COLUMN display_name text;

UPDATE customer
SET display_name = email
WHERE display_name IS NULL;

ALTER TABLE customer
    ALTER COLUMN display_name SET NOT NULL;$code$),
    ('sql-normalization-and-modeling', 1, 'Normalization removes duplication', $body$First normal form requires atomic values and no repeating groups, so an order with a comma-separated list of product ids cannot be filtered or joined cleanly. Second normal form removes partial dependencies on part of a composite key, and third normal form removes transitive dependencies so that a customer city is lookup data rather than a column repeated on every order. Normalized schemas have a single source of truth, which makes updates safe. The cost is more joins, which the planner handles well at typical sizes. Rule of thumb: normalize first and make denormalization a measured decision.$body$, $code$CREATE TABLE order_line (
    order_id bigint NOT NULL REFERENCES orders (id),
    product_id bigint NOT NULL REFERENCES product (id),
    quantity integer NOT NULL,
    PRIMARY KEY (order_id, product_id)
);$code$),
    ('sql-normalization-and-modeling', 2, 'Denormalize only with evidence', $body$Denormalization means copying data to avoid a join or a computation, and it accepts duplication as a cost. Materialized views and cached aggregate columns are common forms, and both require a refresh or update strategy or they drift from the source. Denormalize for a measured bottleneck, not for anticipated performance, and keep the copying logic in one place such as a trigger, a materialized view, or a scheduled job. Rule of thumb: before denormalizing, confirm the join is the actual bottleneck in EXPLAIN ANALYZE.$body$, $code$CREATE MATERIALIZED VIEW customer_order_totals AS
SELECT customer_id, count(*) AS order_count, sum(total_cents) AS revenue_cents
FROM orders
WHERE status = 'PAID'
GROUP BY customer_id;

CREATE UNIQUE INDEX ON customer_order_totals (customer_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY customer_order_totals;$code$),
    ('sql-normalization-and-modeling', 3, 'Naming and type conventions', $body$Consistent naming makes a schema navigable without documentation: plural snake_case table names, singular column names, and foreign keys named after the referenced table such as `customer_id` and `order_id`. Choose types that match the domain: `timestamptz` for instants, `numeric` for money, `text` for strings, and `boolean` for flags. Avoid `varchar(n)` limits copied from an old system unless the limit is a real domain rule. Rule of thumb: settle conventions on the first table and apply them everywhere, including test fixtures and migration scripts.$body$, $code$CREATE TABLE subscription (
    id bigserial PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES customer (id),
    plan_code text NOT NULL,
    started_at timestamptz NOT NULL DEFAULT now(),
    cancelled_at timestamptz
);$code$),
    ('postgresql-jsonb-modeling', 1, 'JSONB storage and operators', $body$The jsonb type stores parsed JSON in a decomposed binary form, supports indexing, and normalizes key order and duplicates; json preserves the original text and is rarely what you want. Access nested values with the `->` operator for json and `->>` for text, and filter with containment using `@>` or key existence using `?`. Containment is top-down and structural, so a nested match requires the full path to appear in the pattern. Rule of thumb: store attributes you never filter on in jsonb, and promote anything you filter or constrain to a real column.$body$, $code$SELECT id, payload ->> 'channel' AS channel
FROM event
WHERE payload @> '{"channel": "email"}'
  AND created_at >= now() - interval '7 days'
ORDER BY created_at DESC
LIMIT 100;$code$),
    ('postgresql-jsonb-modeling', 2, 'GIN indexes for containment', $body$A GIN index on a jsonb column accelerates the containment and existence operators, which makes jsonb usable on large event and payload tables. The default `jsonb_ops` operator class supports `?`, `?|`, `?&`, `@>`, and jsonpath matching; the smaller and faster `jsonb_path_ops` supports only containment and jsonpath, but it is typically more compact. Indexing a single expression, such as one extracted payload key, is an alternative that helps equality queries without indexing the whole document. Rule of thumb: create a GIN index only when queries actually use the operators it supports.$body$, $code$CREATE INDEX idx_event_payload_gin
    ON event
    USING GIN (payload jsonb_path_ops);

CREATE INDEX idx_event_channel
    ON event ((payload ->> 'channel'));$code$),
    ('postgresql-jsonb-modeling', 3, 'When columns beat documents', $body$jsonb is schema flexibility purchased with weaker guarantees: no type checking per key, no NOT NULL or foreign keys inside the document, and statistics that cannot describe individual keys, so the planner may estimate poorly. Updates rewrite the whole column value and lock the row. Good fits are payloads that vary per event and are read as a unit; poor fits are core entities with stable attributes used in joins or reports. Rule of thumb: model stable, queried attributes as columns and keep the document for the variable remainder.$body$, $code$SELECT id, payload ->> 'channel' AS channel
FROM event
WHERE created_at >= now() - interval '1 day'
ORDER BY created_at DESC
LIMIT 100;$code$),
    ('postgresql-partitioning', 1, 'Declarative range partitioning', $body$Declarative partitioning turns one logical table into many physical partitions, and PostgreSQL routes each inserted row to the matching partition by the partition key. Range partitioning suits time-series data because old partitions can be detached or dropped in constant time instead of deleted in small batches. Queries whose WHERE clause constrains the partition key let the planner skip partitions through pruning. Rule of thumb: partition only when the table is large enough to need it, and put the most common time or tenant filter in the key.$body$, $code$CREATE TABLE event_2026_10 PARTITION OF event
    FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');

CREATE TABLE event_2026_11 PARTITION OF event
    FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');

CREATE TABLE event_default PARTITION OF event DEFAULT;$code$),
    ('postgresql-partitioning', 2, 'Pruning and partition-wise plans', $body$Partition pruning depends on a constant comparison on the partition key at planning or execution time, so a query without such a predicate scans every partition and becomes slower than an unpartitioned table. Runtime pruning can still help when the value arrives as a parameter. Partitionwise joins and aggregates can help when both sides are partitioned compatibly. Unique constraints must include the partition key because uniqueness is enforced per partition. Rule of thumb: confirm pruning by comparing EXPLAIN output for the same query with and without a partition key filter.$body$, $code$EXPLAIN (ANALYZE)
SELECT count(*)
FROM event
WHERE created_at >= date '2026-10-01'
  AND created_at < date '2026-11-01';$code$),
    ('postgresql-partitioning', 3, 'Maintenance window operations', $body$Daily or monthly maintenance becomes cheap when partitions arrive and leave on schedule: create the next partition ahead of time so no insert lands in a catch-all default partition, attach it, drop or detach old ones once retention passes, and run per-partition VACUUM and REINDEX instead of table-wide operations. Creating a partition with `CREATE TABLE ... PARTITION OF` takes an ACCESS EXCLUSIVE lock on the parent; creating the table first and using ATTACH PARTITION is friendlier to concurrent traffic. Rule of thumb: automate partition creation and retention so no human action sits on the critical path.$body$, $code$CREATE TABLE event_2026_12
    (LIKE event INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

ALTER TABLE event_2026_12
    ADD CONSTRAINT event_2026_12_range
    CHECK (created_at >= date '2026-12-01'
       AND created_at <  date '2027-01-01');

ALTER TABLE event ATTACH PARTITION event_2026_12
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');$code$),
    ('postgresql-vacuum-and-bloat', 1, 'Dead tuples and MVCC', $body$PostgreSQL keeps old row versions visible to open snapshots, so an UPDATE writes a new version and marks the old one dead rather than overwriting it in place. VACUUM later reclaims space used by dead tuples and updates the visibility map, and that space is reused but not returned to the operating system unless trailing pages become free. A table that updates heavily therefore stays larger than its live data, which is bloat. Rule of thumb: measure bloat from dead tuples rather than from disk size alone, because a large table is not automatically bloated.$body$, $code$SELECT relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 10;

VACUUM (ANALYZE) orders;$code$),
    ('postgresql-vacuum-and-bloat', 2, 'Tuning autovacuum per table', $body$Autovacuum triggers on a formula over the table size, so a large, hot table can accumulate millions of dead tuples before the default scaling threshold fires. Per-table storage parameters override the global settings and are the right lever: lower the vacuum scale factor, lower the threshold, and shorten the cost delay on busy tables so cleanup keeps up. Freezing also matters because anti-wraparound vacuum refuses to be skipped, and a long-running transaction can block removal of any tuple newer than its snapshot. Rule of thumb: tune the busiest few tables explicitly and watch `last_autovacuum`.$body$, $code$ALTER TABLE orders SET (
    autovacuum_vacuum_scale_factor = 0.02,
    autovacuum_vacuum_threshold = 1000,
    autovacuum_vacuum_cost_delay = 1
);$code$),
    ('postgresql-vacuum-and-bloat', 3, 'Measuring and reclaiming bloat', $body$Bloat is estimated by comparing a table physical size with the size its live rows would need, and pgstattuple provides exact numbers when the estimate is not enough. Ordinary VACUUM reclaims space for reuse and keeps the table online; VACUUM FULL rewrites the table and returns space to the operating system but takes an ACCESS EXCLUSIVE lock and needs free disk space roughly equal to the table size. For the largest tables the online alternatives are partitioning or `pg_repack`. Rule of thumb: schedule VACUUM FULL only when the space matters and a maintenance window exists.$body$, $code$SELECT pg_size_pretty(pg_relation_size('orders')) AS table_size,
       pg_size_pretty(pg_indexes_size('orders')) AS index_size,
       pg_size_pretty(pg_total_relation_size('orders')) AS total_size;

VACUUM (VERBOSE, ANALYZE) orders;

VACUUM FULL orders;$code$),
    ('postgresql-connection-pooling', 1, 'Why connections are expensive', $body$Each PostgreSQL connection is a backend process with its own memory for caches, sort space, and catalog state, so hundreds of them consume real CPU and RAM and increase context switching. Opening a connection also costs a TLS handshake and authentication round trips, which makes per-request connections a latency problem. Servers commonly reserve connections for maintenance, so a service that opens a new connection per query will exhaust the limit under load. Rule of thumb: treat connections as a scarce server resource that the application borrows and returns quickly.$body$, $code$HikariConfig cfg = new HikariConfig();
cfg.setJdbcUrl("jdbc:postgresql://db:5432/javacraft");
cfg.setMaximumPoolSize(10);
cfg.setConnectionTimeout(3000);
cfg.setValidationTimeout(1000);
DataSource dataSource = new HikariDataSource(cfg);$code$),
    ('postgresql-connection-pooling', 2, 'HikariCP pool sizing', $body$A pool has a maximum size, and a request that cannot get a connection waits until the timeout and then fails, so timeouts and saturation surface together. Sizing depends on how long each connection is actually busy: with short, transactional queries a surprisingly small pool saturates the work. Watch the pool metrics (active, idle, and pending waits) to distinguish too-small pools from slow queries. Rule of thumb: size the pool so the database is saturated by work, not by threads, and never exceed what the server can serve.$body$, $code$# application.yml
spring.datasource.hikari.pool-name: javacraft-pool
spring.datasource.hikari.maximum-pool-size: 10
spring.datasource.hikari.minimum-idle: 2
spring.datasource.hikari.connection-timeout: 3000
spring.datasource.hikari.max-lifetime: 1800000$code$),
    ('postgresql-connection-pooling', 3, 'Multiplexing with PgBouncer', $body$PgBouncer sits between the application and the server and multiplexes many client connections onto few server connections. In transaction pooling mode a server connection returns to the pool at the end of each transaction, which is the usual choice for web services but forbids session state such as prepared statements, advisory locks, and SET that must survive across transactions. In session mode behavior is fully compatible but multiplexing is far weaker. Rule of thumb: run transaction pooling for pooled, stateless services and keep a direct path for migrations and administration.$body$, $code$# pgbouncer.ini
[databases]
javacraft = host=db port=5432 dbname=javacraft

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20$code$),
    ('postgresql-backup-and-recovery', 1, 'Logical and physical backups', $body$A logical backup exports SQL statements using pg_dump or the directory format, which restores selectively and across versions but is slow and takes a consistent snapshot while it runs. A physical backup copies data files and WAL from a base backup, restoring quickly to the same PostgreSQL major version and enabling point-in-time recovery. Large databases usually need both: physical for recovery objectives, logical for portability and single-table restores. Rule of thumb: choose the tool from the recovery time and recovery point you promised, not from convenience.$body$, $code$pg_dump --format=custom --file=javacraft.dump javacraft

pg_restore --list javacraft.dump | head -20

pg_restore --clean --if-exists --dbname=javacraft javacraft.dump

psql --dbname=javacraft --command="SELECT count(*) FROM orders"

pg_dump --schema-only --file=javacraft-schema.sql javacraft$code$),
    ('postgresql-backup-and-recovery', 2, 'Point-in-time recovery targets', $body$Point-in-time recovery replays archived WAL from a base backup up to a target time, which is how you undo a mistaken migration or a bad batch job without restoring to the previous night. Enabling it requires continuous = on, a working archive_command or pg_receivewal destination, and enough retained WAL to cover the recovery window; without archived WAL the base backup can only be restored to its creation point. A restore must target a stopped server, so practice it in a separate environment. Rule of thumb: monitor archive failures continuously, because a silent gap silently breaks recovery permanently.$body$, $code$# postgresql.conf
wal_level = replica
archive_mode = on
archive_command = 'test ! -f /archive/%f && cp %p /archive/%f'

# recovery target when restoring
# restore_command = 'cp /archive/%f %p'
# recovery_target_time = '2026-10-05 09:30:00+03'$code$),
    ('postgresql-backup-and-recovery', 3, 'Rehearse restores on a schedule', $body$Backups are only as good as the last successful restore, so schedule drills that restore into a scratch instance and check row counts, constraint violations, and application queries against it. Measure how long the restore actually takes and compare it with the recovery time objective; a backup that restores in six hours is not a backup for a two-hour target. Independent copies must live on separate storage and credentials so a compromised or failed primary does not take the backup with it. Rule of thumb: run a restore drill on a fixed cadence and record the measured time.$body$, $code$CREATE DATABASE jc_restore_check;

pg_restore --dbname=jc_restore_check --jobs=4 javacraft.dump

psql --dbname=jc_restore_check --command="SELECT count(*) FROM orders"

psql --dbname=jc_restore_check --command="SELECT count(*) FROM customer"

DROP DATABASE jc_restore_check;$code$),
    ('postgresql-replication-basics', 1, 'Streaming replication with a hot standby', $body$A standby replays the primary WAL stream continuously, giving a hot standby that accepts read-only queries while it recovers. Setting up streaming replication needs a base backup and a replication slot, and wal_level must be replica or higher. Logical replication publishes table changes instead of physical blocks and allows partial replication across versions. Physical replication copies everything, including indexes and bloat, so a standby is byte-for-byte compliant with the primary. Rule of thumb: use one physical standby for availability and failover and logical replication when you need selective or cross-version copies.$body$, $code$SELECT client_addr, state, sync_state, replay_lag
FROM pg_stat_replication;

SELECT application_name, sync_priority
FROM pg_stat_replication
ORDER BY sync_priority;$code$),
    ('postgresql-replication-basics', 2, 'Synchronous durability trade-off', $body$Synchronous replication makes a commit wait until the standby confirms the WAL record was received or flushed, which bounds data loss at the price of commit latency. With `synchronous_commit = remote_apply` the standby has already applied the change, so reads there are consistent; that is the strictest and slowest setting. The setting can be changed per transaction, and `synchronous_standby_names` selects which standbys participate. Rule of thumb: use asynchronous replication for most writes and synchronous only where losing a committed transaction is unacceptable.$body$, $code$SHOW synchronous_commit;

SET synchronous_commit = 'remote_apply';
UPDATE account SET balance = balance - 100 WHERE id = 1;

SET synchronous_commit = 'local';
INSERT INTO audit_log (message) VALUES ('transfer applied');
RESET synchronous_commit;$code$),
    ('postgresql-replication-basics', 3, 'Lag changes what reads mean', $body$Replication lag is the delay between WAL generation on the primary and replay on the standby, and it widens under bulk writes, vacuum, or network trouble. Read replicas served by the application are eventually consistent, so a user can insert a row and then miss it on the next read. Send read-your-writes traffic to the primary, or gate it on a lag measurement, rather than assuming the replica is caught up. Rule of thumb: never route a read to a replica unless you have decided what staleness the user can tolerate.$body$, $code$SELECT EXTRACT(EPOCH FROM replay_lag) AS replay_lag_seconds
FROM pg_stat_replication;

SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS lag_bytes
FROM pg_stat_replication;

SELECT pg_last_wal_replay_lsn();$code$),
    ('database-migrations-at-scale', 1, 'The expand and contract pattern', $body$A schema change that breaks the running application cannot be deployed atomically with the code that adapts to it, so split it into steps. Expand adds the new structure in a backward-compatible way, the application deploys and writes both shapes, a backfill fills existing rows, the application switches reads, and contract removes the old structure once no reader remains. Each step is deployable and reversible on its own. Rule of thumb: never combine a breaking schema change with an application release in the same window.$body$, $code$ALTER TABLE customer ADD COLUMN email_norm text;

UPDATE customer
SET email_norm = lower(trim(email))
WHERE email_norm IS NULL;

CREATE INDEX CONCURRENTLY idx_customer_email_norm
    ON customer (email_norm);$code$),
    ('database-migrations-at-scale', 2, 'Zero-downtime DDL with brief locks', $body$Most DDL in PostgreSQL takes locks, and ACCESS EXCLUSIVE conflicts with everything, so a long ALTER blocks queries and can queue other statements behind it. Adding a nullable column or a constraint with NOT VALID is quick because it does not rewrite data, while changing a type usually rewrites the table. Build indexes with CREATE INDEX CONCURRENTLY, set a short lock_timeout so a blocked migration fails instead of stalling the queue, and avoid long transactions that keep locks alive. Rule of thumb: assume every DDL statement takes ACCESS EXCLUSIVE until you have verified otherwise.$body$, $code$SET lock_timeout = '3s';

ALTER TABLE customer ADD COLUMN tier text;
ALTER TABLE customer
    ADD CONSTRAINT customer_tier_check
    CHECK (tier IN ('free', 'pro')) NOT VALID;

CREATE INDEX CONCURRENTLY idx_customer_tier ON customer (tier);$code$),
    ('database-migrations-at-scale', 3, 'Backfills belong in batches', $body$A single UPDATE over millions of rows holds a transaction open, generates enormous WAL, blocks vacuum, and can fail near the end after hours of work. Batch the backfill by primary key: update a bounded set, commit, and repeat, which bounds lock holding, keeps replication lag manageable, and lets autovacuum reclaim dead tuples between batches. Add constraints only after the data complies, and verify progress with counts. Rule of thumb: every backfill must be restartable, observable, and safe to run while the service is live.$body$, $code$UPDATE customer
SET email_norm = lower(trim(email))
WHERE email_norm IS NULL
  AND id IN (
      SELECT id FROM customer
      WHERE email_norm IS NULL
      ORDER BY id
      LIMIT 5000
  );$code$),
    ('postgresql-full-text-search', 1, 'Documents and queries as tsvector', $body$Full text search parses text into lexemes, normalizes them through a configuration such as english, and stores positions so phrases and ranking work. to_tsvector builds the document vector and to_tsquery, plainto_tsquery, or websearch_to_tsquery builds the query, and @@ tests whether the document matches. websearch_to_tsquery accepts ordinary search box input with quoted phrases and OR, which makes it a good default. Configurations control stemming and stop words, so they must match between indexing and searching. Rule of thumb: pick one configuration per language and use it in both the index and every query.$body$, $code$SELECT title
FROM article
WHERE to_tsvector('english', title || ' ' || body)
      @@ websearch_to_tsquery('english', 'connection pool')
ORDER BY created_at DESC
LIMIT 20;$code$),
    ('postgresql-full-text-search', 2, 'Stored generated columns and GIN', $body$Expressions in the WHERE clause can use an expression index, but a stored generated tsvector column keeps the work off the read path and lets any query use the same vector. A GIN index over that column supports the @@ operator efficiently, at the cost of index size and slower writes. Combining title and body with coalesce keeps NULLs from erasing the whole vector. Rule of thumb: use a stored tsvector column with a GIN index for any search that runs in a request path.$body$, $code$ALTER TABLE article
    ADD COLUMN search_vector tsvector
        GENERATED ALWAYS AS (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(body, ''))) STORED;

CREATE INDEX idx_article_search
    ON article USING GIN (search_vector);

ANALYZE article;$code$),
    ('postgresql-full-text-search', 3, 'Ranking and when to move on', $body$ts_rank and ts_rank_cd score matches using term frequencies, weighting, and proximity, and they are heuristics rather than relevance science: they ignore global term statistics such as how rare a word is. Always keep the search column predicate in the query and order by rank only within matched rows. PostgreSQL handles a few million documents well, but fuzzy matching, typo tolerance, highlighting across languages, or cross-document relevance tuning belong to a dedicated search engine. Rule of thumb: start with PostgreSQL and move when ranking quality becomes the product requirement.$body$, $code$SELECT title,
       ts_rank_cd(search_vector, query) AS score
FROM article,
     websearch_to_tsquery('english', 'connection pool') AS query
WHERE search_vector @@ query
ORDER BY score DESC
LIMIT 20;$code$)
) AS s(slug, sort_order, title, body, starter_code)
JOIN tutorial t ON t.slug = s.slug
WHERE NOT EXISTS (
    SELECT 1
    FROM tutorial_section existing
    WHERE existing.tutorial_id = t.id AND existing.sort_order = s.sort_order
);

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id, t.id,
       COALESCE((SELECT MAX(existing.sort_order)
                 FROM learning_path_tutorial existing
                 WHERE existing.learning_path_id = lp.id), 0)
       + ROW_NUMBER() OVER (PARTITION BY lp.id ORDER BY t.slug)
FROM learning_path lp
JOIN tutorial t ON t.level = CASE lp.slug
    WHEN 'junior-java-developer' THEN 'Junior'
    WHEN 'mid-java-engineer' THEN 'Mid'
    WHEN 'senior-java-engineer' THEN 'Senior'
    WHEN 'lead-java-engineer' THEN 'Lead'
    WHEN 'principal-java-engineer' THEN 'Principal'
END
WHERE t.slug IN (
    'sql-query-fundamentals', 'sql-joins-in-depth',
    'sql-aggregations-and-window-functions', 'sql-indexing-strategy',
    'sql-query-planner-and-explain', 'sql-transactions-and-locking',
    'sql-constraints-and-integrity', 'sql-normalization-and-modeling',
    'postgresql-jsonb-modeling', 'postgresql-partitioning',
    'postgresql-vacuum-and-bloat', 'postgresql-connection-pooling',
    'postgresql-backup-and-recovery', 'postgresql-replication-basics',
    'database-migrations-at-scale', 'postgresql-full-text-search'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
