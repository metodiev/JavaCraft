-- V16 — JPA and Hibernate deep dive.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('hibernate-mapping-basics', 'Hibernate Mapping Basics', 'Map Java classes to tables, columns, and generated identifiers with explicit, production-friendly annotations.', 'Junior', 30, true, 1),
    ('hibernate-entity-lifecycle', 'The Hibernate Entity Lifecycle', 'Follow entities through transient, managed, detached, and removed states and the operations that move them.', 'Junior', 26, true, 1),
    ('jpa-persistence-context', 'Understanding the JPA Persistence Context', 'Use the first-level cache and flush semantics without relying on stale snapshots or context leaks.', 'Junior', 28, true, 1),
    ('jpa-lazy-loading-pitfalls', 'Lazy Loading Pitfalls in JPA', 'Avoid failed lazy initialization and detached graphs by fetching what the use case actually needs.', 'Mid', 30, true, 1),
    ('n-plus-one-problem', 'Detecting the N Plus One Problem', 'Detect one plus N query patterns and fix them with fetch joins, batch fetching, entity graphs, or projections.', 'Mid', 32, true, 1),
    ('jpa-fetch-strategies', 'JPA Fetch Strategies in Practice', 'Choose eager or lazy loading per use case and control fetching at query time with graphs and provider strategies.', 'Mid', 30, true, 1),
    ('hibernate-batch-processing', 'Hibernate Batch Processing at Scale', 'Configure JDBC batching, flush and clear cadence, and memory-safe bulk workflows in Hibernate.', 'Mid', 34, true, 1),
    ('jpa-locking-strategies', 'JPA Locking Strategies', 'Prevent lost updates with version columns, pessimistic locks, and retry policies integrated with transactions.', 'Mid', 36, true, 1),
    ('hibernate-second-level-cache', 'The Hibernate Second-Level Cache', 'Decide when a shared cache pays, how regions and eviction work, and what clustering changes.', 'Mid', 32, true, 1),
    ('jpa-pagination-strategies', 'JPA Pagination Strategies', 'Understand offset and limit semantics, keyset seeking with JPQL, and window-function paging in Hibernate.', 'Mid', 34, true, 1),
    ('hibernate-dirty-checking', 'Hibernate Dirty Checking', 'Learn how Hibernate detects changes, skip tracking for read-only work, and avoid unexpected flushes.', 'Mid', 28, true, 1),
    ('jpa-vs-jdbc-tradeoffs', 'JPA Versus JDBC Trade-Offs', 'Choose between entity management and direct JDBC per access path inside one transaction.', 'Senior', 38, true, 1),
    ('hibernate-schema-generation', 'Hibernate Schema Generation', 'Use ddl-auto safely and keep schema ownership, validation, and drift detection in migrations.', 'Senior', 36, true, 1),
    ('jpa-auditing-and-timestamps', 'JPA Auditing and Timestamps', 'Track creation and modification times, and evaluate Envers history tables and their pitfalls.', 'Senior', 36, true, 1),
    ('hibernate-statistics-and-tuning', 'Hibernate Statistics and Tuning', 'Enable statistics, read query counts as budgets, and connect counters to slow-query evidence.', 'Senior', 38, true, 1),
    ('jpa-criteria-and-specifications', 'JPA Criteria and Specifications', 'Build dynamic JPA queries with Criteria and Specifications without breaking fetch and paging behavior.', 'Senior', 40, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('hibernate-mapping-basics', 1, 'Entities map to tables explicitly', $body$JPA maps a class to a table through annotations, not through convention alone. @Entity declares the persistent type, @Table overrides the table and schema name, and @Column overrides the column name plus hints such as nullability and length. Those hints shape generated DDL and are ignored by some checks, so they cannot replace a real migration. In production the schema is owned by migration scripts, which makes explicit names valuable: a rename in Java should not silently change a column that the database still exposes under its old name. Rule of thumb: pin durable table and column names with @Table and @Column, and treat defaults as a convenience for throwaway prototypes.$body$, $code$@Entity
@Table(name = "orders")
public class Order {
    @Id
    @Column(name = "id")
    private UUID id;

    @Column(name = "total_cents", nullable = false)
    private long totalCents;
}$code$),
    ('hibernate-mapping-basics', 2, 'Choose identifier generation deliberately', $body$GenerationType offers IDENTITY, SEQUENCE, TABLE, UUID, and AUTO. IDENTITY delegates to an auto-increment column and prevents Hibernate from batching inserts, because each insert must return its key immediately. SEQUENCE asks the database for blocks of identifiers; when allocationSize matches the sequence increment, fewer round trips are needed. TABLE emulates a sequence and is slow under contention. AUTO lets the provider choose, which varies by dialect and version, so the same code can behave differently after an upgrade. Explicit UUID keys avoid round trips but are larger and less index-friendly. Rule of thumb: use SEQUENCE with a matching allocationSize for high-volume tables and never let AUTO pick silently.$body$, $code$@Entity
public class Invoice {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "invoice_seq")
    @SequenceGenerator(name = "invoice_seq", sequenceName = "invoice_seq",
            allocationSize = 50)
    private Long id;
}$code$),
    ('hibernate-mapping-basics', 3, 'Implicit naming versus explicit names', $body$Without explicit annotations, names come from naming strategies. Hibernate first applies an implicit strategy that derives names from classes and properties, then a physical strategy that converts camel case to underscores and can alter case or quoting; Spring Boot configures a CamelCaseToUnderscoresNamingStrategy-style physical strategy by default. Explicit @Table and @Column values win over both, which matters when a migration already created a column. The common production failure is drift: developers rename a field, the mapping quietly points at a new column, and the first failing query appears only where the old schema is authoritative. Rule of thumb: treat annotations as the contract with the migration and be explicit wherever the database name matters.$body$, $code$@Entity
@Table(name = "payment")
public class Payment {
    @Column(name = "captured_at", nullable = false)
    private Instant capturedAt;
}$code$),
    ('hibernate-entity-lifecycle', 1, 'Four lifecycle states', $body$Hibernate tracks an entity through transient, managed, detached, and removed states. A new object is transient until persist attaches it to a persistence context. find and getReference return managed instances whose changes are flushed automatically. Closing, clearing, or detaching ends management, producing a detached object that still holds data but is no longer synchronized. remove schedules deletion, which becomes SQL only at flush. State is not a property of the class; it is the relationship between the instance and a specific context, so one row can be represented by several instances in different states. Rule of thumb: know which state an object is in before calling any EntityManager method.$body$, $code$Order order = new Order();                  // transient
entityManager.persist(order);               // managed
entityManager.flush();                      // INSERT executed
entityManager.detach(order);                // detached
Order managed = entityManager.merge(order); // managed copy
entityManager.remove(managed);              // removed$code$),
    ('hibernate-entity-lifecycle', 2, 'Persist versus merge', $body$persist attaches a transient instance and returns void, so callers keep the same reference. merge copies the state of a detached instance into a managed copy and returns that copy; the argument stays detached. After merge, generated values such as identifiers and versions exist only on the returned instance, which is why building a response from the argument is a classic bug. Calling persist on an instance that already has an identifier can raise PersistentObjectException, while merge on an unknown identifier performs an insert. For updates from the web layer, merge is convenient but hides whether the row exists. Rule of thumb: always use the instance returned by merge and flush before reading generated values.$body$, $code$Order detached = buildOrder(request);
Order managed = entityManager.merge(detached);
entityManager.flush();
UUID id = managed.getId();
return toResponse(managed);$code$),
    ('hibernate-entity-lifecycle', 3, 'Scope contexts to the unit of work', $body$A persistence context that lives longer than one business operation turns reads into tracked writes: any setter called later changes the database at the next flush, even if the caller only meant to copy data. Detached objects that cross layers cannot initialize lazy associations, and merging them can overwrite columns with stale values. Keeping the context open for an entire HTTP request, as OpenEntityManagerInView does, hides these boundaries and holds resources while the view renders. The alternative is mapping to explicit objects at the boundary and reattaching deliberately. Rule of thumb: one persistence context per unit of work, closed when that work finishes.$body$, $code$@Transactional
public OrderResponse rename(UUID id, String reference) {
    Order order = repository.findById(id).orElseThrow();
    order.setReference(reference);   // flushed automatically
    return new OrderResponse(order.getId(), order.getReference());
}$code$),
    ('jpa-persistence-context', 1, 'First-level cache and identity', $body$Every managed entity lives in the persistence context, which acts as a transactional first-level cache. A second find for the same identifier returns the identical instance without hitting the database, and Hibernate guarantees that two references to one row in one context are the same object. That identity guarantee does not extend across contexts: after clear or in another transaction, code receives a different instance representing the same row. Code that compares entities with reference equality therefore works in one scope and fails in another. The cache also explains why an update followed by a find may execute no SQL: the context already owns the state. Rule of thumb: compare by identifier, never by reference.$body$, $code$Order first = entityManager.find(Order.class, id);
Order second = entityManager.find(Order.class, id);
boolean sameInstance = first == second;   // true in one context

entityManager.clear();
Order afterClear = entityManager.find(Order.class, id);
boolean stillSame = first == afterClear;  // false, a new instance$code$),
    ('jpa-persistence-context', 2, 'Flush versus commit', $body$Flush synchronizes pending changes with the database by executing SQL, but it does not make them permanent or visible to other transactions; only commit does that, and a rollback discards flushed work. Hibernate flushes automatically before queries when dirty state overlaps their query spaces, and again at commit. FlushModeType.COMMIT defers those automatic flushes until the transaction ends, which reduces surprise statements but lets queries read stale rows. Flushing also does not empty the context, so entities stay managed and dirty checking continues. The frequent production mistake is treating a flush as a durability point, then losing data on rollback. Rule of thumb: flush to make SQL happen, commit to make changes real.$body$, $code$entityManager.getTransaction().begin();
entityManager.persist(order);
entityManager.flush();     // INSERT executed, not yet committed
// a rollback here discards the flushed statement
entityManager.getTransaction().commit();$code$),
    ('jpa-persistence-context', 3, 'Scopes that create stale reads', $body$Persistence context scope determines what a query can see. In a request-scoped setup the context survives many queries, so an entity loaded early keeps its snapshot even after another transaction commits a new value; refresh is the explicit escape hatch. Long-lived contexts also grow with every entity touched, slowing dirty checking and increasing memory use, while detached instances from past requests cannot load lazy data. Extended contexts and long conversations make this worse because state lives for hours. Rule of thumb: keep the context as short as the business operation allows, and refresh only when reading the row again is genuinely required.$body$, $code$Order order = entityManager.find(Order.class, id);  // snapshot loaded
// another transaction commits a new value for the row
entityManager.refresh(order);                       // reload current state
if (order.getStatus() == Status.PAID) {
    ship(order);
}$code$),
    ('jpa-lazy-loading-pitfalls', 1, 'What a lazy proxy does', $body$FetchType.LAZY defers loading. A to-one association becomes a proxy that holds the identifier and initializes on first access to any other property; a to-many association becomes an uninitialized collection. Initialization needs an open persistence context, because the proxy must execute SQL through it. Accessing only the identifier of a proxy usually avoids a query, which is why reading an association id is safe. Lazy is the default for to-many associations and the explicit recommendation for to-one, since eager chains create joins the application never uses. Rule of thumb: keep mappings lazy and decide fetches per query.$body$, $code$@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(name = "customer_id")
private Customer customer;

Customer customer = order.getCustomer();  // proxy until a field is read
String name = customer.getName();         // triggers the SELECT$code$),
    ('jpa-lazy-loading-pitfalls', 2, 'Lazy initialization at the boundary', $body$LazyInitializationException means an uninitialized proxy was touched after its persistence context closed. It most often appears in serialization: a framework walks entity properties outside the service method and triggers loading on a detached graph. Catching the exception is not a fix, and switching associations to EAGER moves the cost to every other use case. The workable options are fetching exactly what the use case needs inside the transaction, mapping to a DTO before returning, or keeping an explicit fetch plan per query. Rule of thumb: close the unit of work with fully initialized data or plain values, never with live proxies.$body$, $code$Order order = entityManager.createQuery(
        "select o from Order o join fetch o.customer where o.id = :id",
        Order.class)
    .setParameter("id", id)
    .getSingleResult();

String name = order.getCustomer().getName();  // already initialized$code$),
    ('jpa-lazy-loading-pitfalls', 3, 'Detached graphs on the wire', $body$Serializing entities sends two things the API did not agree to: internal structure and lazy state. The first access to each uninitialized association either fails or fires its own query, and the resulting payload depends on which getters the serializer happens to call. Detached instances are also no longer tracked, so a client-side change round-tripped through the service is silently lost unless merge is used, and merge then reintroduces version conflicts. An explicit DTO built inside the transaction makes the contract stable and the query plan visible. Rule of thumb: entities stay inside the persistence layer and the wire carries DTOs.$body$, $code$record OrderView(UUID id, String customerName) {}

OrderView view = entityManager.createQuery(
        "select new OrderView(o.id, c.name) "
            + "from Order o join o.customer c where o.id = :id",
        OrderView.class)
    .setParameter("id", id)
    .getSingleResult();$code$),
    ('n-plus-one-problem', 1, 'Recognizing one plus N', $body$The N plus one problem is one query to load a list, then one additional query per element when code touches a lazy association. Query counts scale with result size, so a page of twenty rows may cost twenty-one statements; latency grows with the dataset while the code looks linear and harmless. Detection is straightforward: count statements per request with Hibernate statistics, datasource proxies, or SQL logging, and assert a budget in tests. The extra loop is often hidden inside mapping code, where each iteration reads customer or lines. Rule of thumb: suspect any query executed inside a loop over query results.$body$, $code$Statistics stats = entityManager.getEntityManagerFactory()
    .unwrap(SessionFactory.class)
    .getStatistics();
long before = stats.getPrepareStatementCount();
reportService.render(orderIds);
long statements = stats.getPrepareStatementCount() - before;$code$),
    ('n-plus-one-problem', 2, 'Fetch joins and their limits', $body$A join fetch loads an association in the same statement, which removes the extra queries. Two caveats matter in production. First, paginating a query that also fetches a collection can be applied in memory: Hibernate may warn that firstResult and maxResults could not be pushed to SQL, so the database returns everything and the provider trims rows. Second, fetching two collections at once multiplies rows, and bag semantics trigger MultipleBagFetchException; switching to a Set changes collection semantics rather than solving it. Rule of thumb: fetch one collection per query, keep the id set small or use keyset paging, and prefer batch fetching when collections are large.$body$, $code$List<Order> orders = entityManager.createQuery(
        "select distinct o from Order o join fetch o.lines "
            + "where o.status = :status",
        Order.class)
    .setParameter("status", Status.OPEN)
    .getResultList();$code$),
    ('n-plus-one-problem', 3, 'Batching, graphs, and projections', $body$Batch fetching initializes proxies in groups: with a batch size of fifty, Hibernate issues one IN query per fifty parents instead of one per parent, turning one plus N into a small constant. Entity graphs express the same intent declaratively per repository method, so the fetch plan is visible at the call site and testable. Neither helps when a read endpoint needs three columns from a large aggregate; a constructor or interface projection skips entity loading, dirty checking, and snapshot memory entirely. Rule of thumb: fetch plans for write paths that must preserve invariants, DTO projections for read screens.$body$, $code$@EntityGraph(attributePaths = {"customer"})
List<Order> findAllByStatus(Status status);

// read screen that needs three columns
List<OrderSummary> summaries =
    orderSummaryRepository.findAllByStatus(Status.OPEN);$code$),
    ('jpa-fetch-strategies', 1, 'The mapping defaults', $body$The JPA specification makes to-one associations eager and to-many associations lazy. That default is a trap: every @ManyToOne left eager is joined on every load that touches the entity, and chains of eager to-one mappings multiply joins even when the caller needs one field. Making to-one lazy is safe when the code accesses only the identifier, because no initialization occurs, and it keeps query cost under the caller control. Collections should generally stay lazy, since an eager collection on a frequently loaded entity is a full table read waiting to happen. Rule of thumb: mappings provide safe defaults, queries choose what to fetch.$body$, $code$@ManyToOne(fetch = FetchType.LAZY, optional = false)
@JoinColumn(name = "customer_id", nullable = false)
private Customer customer;

@OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
private List<OrderLine> lines = new ArrayList<>();$code$),
    ('jpa-fetch-strategies', 2, 'Entity graphs at query time', $body$An entity graph names attributes to fetch and can be applied per query through hints or repository methods. The fetch graph hint treats attributes not listed as lazy, ignoring the mapping; the load graph hint keeps mapping defaults for everything unlisted. That distinction matters: a load graph can still trigger eager joins you meant to avoid. Graphs also compose badly with pagination over collections, because the provider may paginate in memory, and two collection fetches produce a cartesian row explosion. Rule of thumb: one graph per use case, one collection per graph, and always verify the SQL it generates.$body$, $code$EntityGraph graph = entityManager.getEntityGraph("Order.withLines");
Map<String, Object> hints =
    Map.of("jakarta.persistence.fetchgraph", graph);

Order order = entityManager.find(Order.class, id, hints);$code$),
    ('jpa-fetch-strategies', 3, 'Subselect and batch fetching', $body$Subselect fetching initializes a collection for all entities of the original query with a single statement that filters by an IN subquery, which is efficient when a page of parents is loaded together and wasteful when a single parent is read. Batch fetching is similar but splits keys into fixed-size groups, so it adapts to both shapes and works for to-one proxies as well. Both are configured on the mapping or globally, and both trade a predictable number of bigger queries for fewer small ones. Rule of thumb: measure query counts before and after, and prefer the strategy that matches the access shape.$body$, $code$@OneToMany(mappedBy = "order")
@Fetch(FetchMode.SUBSELECT)
private List<OrderLine> lines = new ArrayList<>();

@BatchSize(size = 50)   // same idea for entity proxies
private Customer customer;$code$),
    ('hibernate-batch-processing', 1, 'Enable JDBC batching correctly', $body$Hibernate batches inserts and updates only when the JDBC driver supports it and a batch size is configured, for example hibernate.jdbc.batch_size in the range of ten to fifty. Grouping matters: order_inserts and order_updates sort statements by entity type so identical statements become contiguous and actually combine, and identity generation must be avoided because batched inserts cannot return generated keys one by one. Some drivers also need batch_versioned_data to report affected rows for versioned updates. Configuration alone is not proof, so confirm in driver logs that the expected statements are sent as a batch. Rule of thumb: sequences for identifiers, ordering enabled, and verified round trips.$body$, $code$Session session = entityManager.unwrap(Session.class);
session.setJdbcBatchSize(50);
for (Item item : items) {
    entityManager.persist(item);
}$code$),
    ('hibernate-batch-processing', 2, 'Flush and clear cadence', $body$Batch jobs that iterate thousands of rows accumulate managed entities and their snapshots in the persistence context, which slows dirty checking and grows memory. The standard pattern flushes and clears every few hundred records: flush sends the statements, clear detaches everything, and the next iteration starts with an empty context. Clearing has a price, because any reference held outside the loop becomes detached and later writes against it are ignored unless merged. Flushing before clear also keeps the timing of statement errors predictable. Rule of thumb: pick a cadence, flush and clear, and never hold managed references across the boundary.$body$, $code$for (int i = 0; i < items.size(); i++) {
    entityManager.persist(toEntity(items.get(i)));
    if (i % 100 == 99) {
        entityManager.flush();
        entityManager.clear();
    }
}$code$),
    ('hibernate-batch-processing', 3, 'Memory traps in bulk loads', $body$The persistence context is the main memory risk in bulk work, not JDBC buffers: every managed entity is retained with a snapshot for dirty checking, so importing a million rows through EntityManager can exhaust the heap long before the database complains. Options include projections for reads, StatelessSession for writes that do not need identity or cascades, and raw JDBC for maximum throughput. Long transactions also hold locks and grow the write-ahead log, so the transaction should be scoped to a batch rather than the whole file. Rule of thumb: batch the unit of work, not only the SQL, and bound both the context and the transaction.$body$, $code$try (StatelessSession session =
         sessionFactory.openStatelessSession()) {
    Transaction tx = session.beginTransaction();
    for (Item item : items) {
        session.insert(item);
    }
    tx.commit();
}$code$),
    ('jpa-locking-strategies', 1, 'Optimistic locking with a version column', $body$An @Version field makes Hibernate include the loaded version in the WHERE clause of every update and increment it on success. If another transaction already changed the row, no row matches, and the provider raises OptimisticLockException, which prevents lost updates without holding database locks. The version column must be managed by the provider, not assigned by application code, and detached merges participate in the same check. Retrying requires a fresh read inside a new transaction, since the failed unit of work has already rolled back. Rule of thumb: optimistic locking is the default for request-driven updates.$body$, $code$@Entity
public class Account {
    @Id
    private Long id;

    @Version
    private long version;

    private long balanceCents;
}$code$),
    ('jpa-locking-strategies', 2, 'Pessimistic locks and their cost', $body$Pessimistic locking asks the database to hold a lock, typically through SELECT FOR UPDATE for PESSIMISTIC_WRITE, so no other writer can change the row until the transaction ends. That removes retries but serializes contenders, makes lock timeouts and deadlocks part of the failure model, and turns a slow downstream call inside the transaction into a global wait. Read and write modes differ by database: some engines do not implement PESSIMISTIC_READ separately. For simple counters, an atomic UPDATE with a WHERE guard often beats both approaches. Rule of thumb: pessimistic locks only around short critical sections, always with a timeout.$body$, $code$Account account = entityManager.find(Account.class, id,
        LockModeType.PESSIMISTIC_WRITE);   // SELECT ... FOR UPDATE
account.debit(amountCents);
entityManager.flush();
// the row lock is held until commit or rollback$code$),
    ('jpa-locking-strategies', 3, 'Retries and integration', $body$Optimistic failures are expected outcomes, so the retry belongs above the transaction boundary: catch the exception after rollback, re-read the aggregate, and try again with a cap and backoff. Spring offers Retryable on optimistic locking exceptions, and any equivalent policy works if it starts a new transaction. Retrying inside the failed transaction cannot succeed because the context is in rollback-only state. Pessimistic timeouts and deadlock victims surface as their own exceptions and should be classified separately, since a deadlock often means lock ordering must change. Rule of thumb: retry the unit of work, never a statement, and never retry blindly.$body$, $code$@Retryable(retryFor = OptimisticLockingFailureException.class,
        maxAttempts = 3, backoff = @Backoff(delay = 50))
@Transactional
public void transfer(TransferCommand command) {
    Account from = accounts.findById(command.fromId()).orElseThrow();
    Account to = accounts.findById(command.toId()).orElseThrow();
    from.debit(command.amountCents());
    to.credit(command.amountCents());
}$code$),
    ('hibernate-second-level-cache', 1, 'When the shared cache pays', $body$The second-level cache is shared across sessions in one JVM and stores entity and collection state by region, so repeated reads of rarely changed reference data can skip the database entirely. It is disabled by default and needs a cache provider plus a region factory; entities opt in with @Cache and a concurrency strategy. The cache pays only when reads greatly outnumber writes and staleness is either impossible or acceptable. Caching mutable, tenant-specific, or security-sensitive data without a clear invalidation story is how stale permissions appear. Rule of thumb: start with immutable lookup data, and require an invalidation answer for anything else.$body$, $code$@Entity
@Cache(usage = CacheConcurrencyStrategy.READ_ONLY)
public class Country {
    @Id
    private String code;

    private String name;
}$code$),
    ('hibernate-second-level-cache', 2, 'Regions, strategies, and eviction', $body$Each cached entity and collection has its own region, and the concurrency strategy decides consistency: READ_ONLY for data that never changes, READ_WRITE with version checks for updates, NONSTRICT_READ_WRITE when brief staleness is tolerable, and TRANSACTIONAL only with a transactional provider. The query cache is separate and stores result identifiers keyed by query and parameters, which means it must be enabled per query and is invalidated when the mapped tables change. Eviction is explicit through the SessionFactory cache API, whole region or single entry. Rule of thumb: pick the weakest strategy that keeps correctness, and rehearse eviction before an incident.$body$, $code$Cache cache = sessionFactory.getCache();
cache.evictEntityData(Country.class, "BG");    // single entry
cache.evictEntityData(Country.class);          // entire entity region
cache.evictCollectionData(Country.class, "cities");
cache.evictQueryRegion("country-queries");     // cached result set$code$),
    ('hibernate-second-level-cache', 3, 'Caching across a cluster', $body$The built-in providers are local to one JVM, so an update on one node does not invalidate entries on another; cluster deployments need a distributed cache or an invalidation protocol such as the ones Infinispan or Hazelcast provide. That is why read-only reference data is the safe default: nothing changes, so nothing needs invalidating. For mutable entities, stale reads can survive until eviction, and mixing cached access with bulk updates or native SQL bypasses invalidation entirely. Cache contents also do not roll back with the database unless the strategy is transactional. Rule of thumb: treat the cache as a consistency boundary and only cache data whose staleness you can explain.$body$, $code$SessionFactory sf = entityManager.getEntityManagerFactory()
    .unwrap(SessionFactory.class);
sf.getCache().evictEntityData(Country.class);
// a local provider does not invalidate the same region on other nodes;
// a clustered provider publishes the invalidation to every member$code$),
    ('jpa-pagination-strategies', 1, 'What offset and limit really mean', $body$setFirstResult sets an offset in rows, not a page number, and setMaxResults sets a limit; together they become OFFSET and LIMIT or the dialect equivalent. Deep offsets force the database to read and discard rows, so the last page costs far more than the first. A second trap is combining pagination with a collection fetch: the provider may warn that firstResult and maxResults were applied in memory, meaning the whole result was loaded and trimmed in Java. Rule of thumb: offset paging for shallow pages only, always with a deterministic order that includes a unique tiebreaker.$body$, $code$List<Order> page = entityManager.createQuery(
        "select o from Order o order by o.createdAt desc, o.id desc",
        Order.class)
    .setFirstResult(pageIndex * pageSize)
    .setMaxResults(pageSize)
    .getResultList();$code$),
    ('jpa-pagination-strategies', 2, 'Keyset pagination with JPQL', $body$Keyset, or seek, pagination remembers the sort key of the last row and asks for rows after it, so the database uses the index and cost stays flat regardless of depth. The order key must be unique or completed with a tiebreaker such as the identifier, and the cursor is usually the pair of values encoded into the response. In JPQL the tuple comparison is written as a greater-than or less-than on the main column OR an equality plus tiebreaker comparison. The trade-offs are no random page access and a cursor that must be opaque and validated. Rule of thumb: keyset for large or infinite feeds, offset for admin screens with page numbers.$body$, $code$List<Order> next = entityManager.createQuery(
        "select o from Order o "
            + "where o.createdAt < :lastCreated "
            + "or (o.createdAt = :lastCreated and o.id < :lastId) "
            + "order by o.createdAt desc, o.id desc",
        Order.class)
    .setParameter("lastCreated", cursor.createdAt())
    .setParameter("lastId", cursor.id())
    .setMaxResults(pageSize)
    .getResultList();$code$),
    ('jpa-pagination-strategies', 3, 'Window functions and counts', $body$Hibernate 6 HQL supports window functions such as row_number, so ranking and paging can be expressed inside the query, and a count over the result set can be returned alongside the page. Because window functions are evaluated before LIMIT, computing a total this way usually requires a subquery. The alternative, a separate count query, scans the same rows again and becomes the most expensive part of a listing endpoint. Many interfaces do not need an exact total: a has-next flag or an approximate count is often acceptable. Rule of thumb: never add a count query to a hot endpoint without measuring it.$body$, $code$List<Object[]> rows = entityManager.createQuery(
        "select o, count(*) over () from Order o order by o.id",
        Object[].class)
    .setMaxResults(pageSize)
    .getResultList();

long approximateTotal = rows.isEmpty()
    ? 0
    : ((Number) rows.get(0)[1]).longValue();$code$),
    ('hibernate-dirty-checking', 1, 'How updates are detected', $body$Hibernate does not require save calls for managed entities. At flush time it compares each entity current property values with the snapshot taken when it was loaded, and emits UPDATE statements only for changes it can see. With bytecode enhancement, tracking can be field-level and cheaper, which matters when a transaction manages thousands of entities. The cost is proportional to managed entities and their mapped columns, so a read-only transaction that loads large graphs pays dirty checking for nothing. Changes made outside setters through reflection or direct field access in enhanced mode may be missed. Rule of thumb: keep the set of managed entities as small as the work requires.$body$, $code$Order order = entityManager.find(Order.class, id);
order.setStatus(Status.PAID);
entityManager.flush();   // UPDATE emitted here, not before
order.setReference("ref-2");
// flush is driven by snapshots, not by explicit save calls$code$),
    ('hibernate-dirty-checking', 2, 'Read-only entities and projections', $body$Read paths can opt out of tracking. A query hint marks results read-only, the session can default to read-only, and a truly immutable mapping avoids snapshots entirely; read-only transactions let the provider skip snapshot copies and dirty checking. Modifications to a read-only entity are silently ignored, which is exactly the trade-off to state in a comment. Projections go further: constructor expressions and interface-based projections are plain values that never enter the persistence context. Rule of thumb: mark read-only work read-only, and use projections when the result is not an aggregate you intend to change.$body$, $code$List<Order> orders = entityManager.createQuery(
        "select o from Order o where o.status = :status", Order.class)
    .setParameter("status", Status.SHIPPED)
    .setHint("org.hibernate.readOnly", true)
    .getResultList();$code$),
    ('hibernate-dirty-checking', 3, 'Flushes you did not ask for', $body$FlushModeType.AUTO flushes before queries whose query spaces overlap dirty entities, so a JPQL query can push pending updates earlier than expected, and a later failure rolls them back together with the read. Bulk JPQL updates and deletes bypass the persistence context: affected entities in memory keep old values and old snapshots, so subsequent reads return stale data until refresh or clear. They also cannot cascade and do not fire lifecycle callbacks. Mixing bulk statements with managed state in one transaction is the usual source of surprises. Rule of thumb: run bulk DML first or in its own transaction, then clear.$body$, $code$entityManager.createQuery(
        "update Order o set o.status = :expired where o.status = :open")
    .setParameter("expired", Status.EXPIRED)
    .setParameter("open", Status.OPEN)
    .executeUpdate();
entityManager.clear();   // drop stale snapshots loaded before the bulk update$code$),
    ('jpa-vs-jdbc-tradeoffs', 1, 'Aggregates versus sets', $body$JPA earns its keep on transactional aggregates: it tracks identity, applies optimistic versions, cascades lifecycles, and keeps the object graph consistent. JDBC earns its keep on set-oriented work: reports, exports, bulk updates, and any query whose result is not an entity needs none of that machinery. Loading entities to render a report pays for snapshots, dirty checking, and lazy surprises while returning columns the screen never shows. The two can live side by side; the failure mode is bending an aggregate mapping to answer an analytical question. Rule of thumb: choose per access path, not per table, and let the read model decide the shape of the query.$body$, $code$jdbcTemplate.query(
    "select c.id, sum(o.total_cents) "
        + "from customer c join orders o on o.customer_id = c.id "
        + "group by c.id",
    (rs, rowNum) -> new CustomerTotal(rs.getLong(1), rs.getLong(2)));$code$),
    ('jpa-vs-jdbc-tradeoffs', 2, 'Mixing safely in one transaction', $body$When JPA and JDBC share a DataSource and transaction manager, they join the same transaction, but they do not share state. JDBC cannot see pending JPA changes until the context flushes, and the persistence context cannot see raw writes until entities are refreshed or cleared. Ordering therefore becomes a correctness property: flush before handing control to raw SQL, and clear after raw SQL changes rows the context already holds. Connection pool limits apply to both paths, so mixing does not add capacity. Rule of thumb: make the boundary explicit with a flush and a clear, and never assume either side sees the other uncommitted state.$body$, $code$entityManager.persist(order);
entityManager.flush();        // pending changes reach the shared connection
jdbcTemplate.update(
    "insert into audit_log (order_id) values (?)", order.getId());
entityManager.clear();        // snapshots are stale after raw writes$code$),
    ('jpa-vs-jdbc-tradeoffs', 3, 'Shape reads for the reader', $body$Read models should be shaped by the consumer, not by the aggregate. Constructor expressions, interface projections, and native queries return exactly the needed columns, avoid entity loading and dirty checking, and make query plans predictable. They also decouple the API contract from mapping refactors, since renaming an entity field no longer changes the payload. The cost is more query code to maintain and less reuse of mappings. Most performance incidents in read-heavy services come from using entities where a projection was enough. Rule of thumb: if a path never writes and does not need the whole aggregate, do not load an entity.$body$, $code$List<OrderSummary> summaries = entityManager.createQuery(
        "select new OrderSummary(o.id, o.status, size(o.lines)) "
            + "from Order o where o.customer.id = :customerId",
        OrderSummary.class)
    .setParameter("customerId", customerId)
    .getResultList();$code$),
    ('hibernate-schema-generation', 1, 'ddl-auto modes and their meaning', $body$ddl-auto has four relevant values: none does nothing, validate compares the mapping with the existing schema and fails startup on mismatch, update attempts additive changes, and create or create-drop rebuilds schema for ephemeral environments. update is dangerous because it never removes columns, cannot rename reliably, and makes each environment drift from the migration history; a column added in staging may not exist in production. validate is the production-friendly mode, catching mismatches at deploy time instead of at the first query. Rule of thumb: none or validate in every shared environment, create only in disposable test databases.$body$, $code$# set per environment; production never relies on generated DDL
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.hbm2ddl.auto=validate
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration$code$),
    ('hibernate-schema-generation', 2, 'Migrations own production DDL', $body$Schema changes need review, ordering, backfills, and a rollback story, which generated DDL cannot express. Flyway or Liquibase scripts are versioned, repeatable, and auditable, and they can move data as well as shape it: add a nullable column, backfill it, then enforce NOT NULL. Hibernate can still validate the result, but it should never race the migration tool to define the schema. Keeping the mapping and the migration in lockstep also means indexes, constraints, and types are visible in one review. Rule of thumb: exactly one owner for DDL, and it is never the application runtime.$body$, $code$@Entity
public class Order {
    // column added by a migration, validated on startup
    @Column(name = "reference", length = 120)
    private String reference;
}$code$),
    ('hibernate-schema-generation', 3, 'Validation and drift detection', $body$Validate compares mapped tables, columns, and types against the live schema and refuses to start when something is missing, which turns a silent runtime failure into a deployment failure. It is not a full equivalence check: some constraints, index details, and dialect-specific types are outside its scope, so it cannot prove that migrations and mappings agree in every respect. Running the application once against a migration-built schema in continuous integration catches drift while it is still cheap, before the change reaches an environment with real data. Rule of thumb: validate everywhere, and treat a validation failure as a schema bug, not a nuisance to disable.$body$, $code$@Entity
@Table(name = "orders")
public class Order {
    // validate fails startup when either name is wrong
    @Column(name = "total_cents", nullable = false)
    private long totalCents;
}$code$),
    ('jpa-auditing-and-timestamps', 1, 'Creation and modification timestamps', $body$Timestamps can be set in application callbacks or by database defaults. Hibernate annotations such as CreationTimestamp and UpdateTimestamp, and Spring Data equivalents CreatedDate and LastModifiedDate with auditing enabled, cover the common cases; JPA lifecycle callbacks such as PrePersist and PreUpdate cover everything else. A mapped superclass keeps the fields and listener in one place. The pitfalls are type and clock: LocalDateTime has no offset and becomes ambiguous across zones, and application clocks drift between nodes, so a database-generated time is often the better authority. Rule of thumb: store Instant in a timestamp-with-time-zone column and generate it in exactly one place.$body$, $code$@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class AuditedEntity {
    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private Instant updatedAt;
}$code$),
    ('jpa-auditing-and-timestamps', 2, 'Change history with Envers', $body$Hibernate Envers records every audited change into revision tables, typically an _AUD table per entity plus revision metadata, with all changes from one transaction sharing a revision number. The AuditReader reads state at a revision, lists revisions for an entity, and queries changed entities between revisions, which supports reconstructions and audits that plain timestamp columns cannot. The cost is real: each write adds audit rows, storage grows with update frequency, and the audit schema must be migrated like any other table. It also does not record the actor unless a custom revision entity stores one. Rule of thumb: audit deliberately, with retention planned before enabling.$body$, $code$@Audited
@Entity
public class Account {
    @Id
    private Long id;
    private long balanceCents;
}

AuditReader reader = AuditReaderFactory.get(entityManager);
Account past = reader.find(Account.class, id, revision);$code$),
    ('jpa-auditing-and-timestamps', 3, 'Temporal data pitfalls', $body$Temporal tables grow monotonically, so queries and retention plans must exist before the data does. Indexes on the entity identifier and revision are essential, and joins from current rows to audit rows can explode. Deleting a row leaves its audit history, which is usually desired but surprises code that assumes an audit row implies a live entity. Bulk updates through JPQL or native SQL bypass Envers unless explicitly handled, so history silently loses changes. Storing who made the change requires a custom revision entity plus a listener that captures the current principal. Rule of thumb: decide actor, retention, and bypass policy at design time, not after the first audit request.$body$, $code$@Entity
@RevisionEntity(AuditListener.class)
public class RevInfo extends DefaultRevisionEntity {
    private String actor;

    public void setActor(String actor) { this.actor = actor; }
}

class AuditListener implements RevisionListener {
    @Override
    public void newRevision(Object revisionEntity) {
        ((RevInfo) revisionEntity).setActor(currentActor());
    }
}$code$),
    ('hibernate-statistics-and-tuning', 1, 'Enable statistics first', $body$Hibernate exposes counters through the SessionFactory statistics API: prepared statement count, entity and collection fetch counts, insert and update counts, transaction counts, and second-level cache hits and misses. Enable them with hibernate.generate_statistics and read them per scenario; Spring Boot can publish the same numbers to Micrometer for dashboards. The overhead is modest but not zero, so keep the setting on in staging and tests rather than assuming it is free in production. Numbers answer questions intuition cannot, such as whether a screen executes five or five hundred statements. Rule of thumb: never tune persistence before the counters are visible.$body$, $code$Statistics stats = entityManager.getEntityManagerFactory()
    .unwrap(SessionFactory.class)
    .getStatistics();
long inserts = stats.getEntityInsertCount();
long fetches = stats.getEntityFetchCount();
long statements = stats.getPrepareStatementCount();$code$),
    ('hibernate-statistics-and-tuning', 2, 'Read query counts as a budget', $body$A handful of statements per request is normal; counts that grow with result size mean N plus one, and counts that exceed the number of distinct pieces of data usually mean duplicate loads or cartesian products. A near-zero cache hit ratio says the second-level cache earns nothing, and a high statement count with low row counts often points at chatty flush or version checks. Give each endpoint a statement budget in a test so regressions fail in continuous integration instead of under peak load. Rule of thumb: budgets and dashboards, not anecdotes.$body$, $code$long before = stats.getPrepareStatementCount();
List<Order> orders = orderService.recentOrders();
long budget = 5;
if (stats.getPrepareStatementCount() - before > budget) {
    throw new IllegalStateException("statement budget exceeded");
}$code$),
    ('hibernate-statistics-and-tuning', 3, 'From counters to changes', $body$Counters tell you where to look, not what to change. Correlate the spike with slow-query logs that include parameters, then read execution plans to see whether an index is missing, a join is exploding, or a sort is spilling to disk. Check connection pool wait time too: an under-sized pool looks identical to a slow query from the outside. Change one thing, re-measure the same scenario, and keep the before and after numbers in the change description. Rule of thumb: one change, one measurement, and never optimize what the plan already handles well.$body$, $code$long start = System.nanoTime();
List<Order> orders = repository.findByStatus(Status.OPEN);
long millis = (System.nanoTime() - start) / 1_000_000;
long statements = stats.getPrepareStatementCount() - before;
log.info("orders status={} statements={} millis={}",
    Status.OPEN, statements, millis);$code$),
    ('jpa-criteria-and-specifications', 1, 'Programmatic queries with Criteria', $body$The Criteria API builds a query from typed parts: a CriteriaBuilder factory, a CriteriaQuery for the result type, and one or more roots. Predicates compose predictably, parameters bind typed values, and because the query is an object it can be assembled from optional filters without string concatenation. The container owns and mutates the query object, so a CriteriaQuery should not be shared across threads or stored for later reuse. Joining the same association twice produces duplicate rows, and reusing a root after the query is built is not supported. Rule of thumb: build fresh per execution and keep composition in small named methods.$body$, $code$CriteriaBuilder cb = entityManager.getCriteriaBuilder();
CriteriaQuery<Order> cq = cb.createQuery(Order.class);
Root<Order> root = cq.from(Order.class);
cq.select(root).where(cb.and(
    cb.equal(root.get("status"), Status.OPEN),
    cb.greaterThan(root.get("totalCents"), minCents)));
List<Order> orders = entityManager.createQuery(cq).getResultList();$code$),
    ('jpa-criteria-and-specifications', 2, 'Composing Specifications safely', $body$Specification wraps a predicate factory and makes filters composable: and, or, and not combine them, and returning null means no restriction rather than false. That null convention is the point and the trap, since filters written as boolean expressions behave differently. Specifications can also set distinct or ordering through the query object, but changing the result type or adding fetches from a specification breaks the contract of repository finders. Small named specifications with their own tests keep dynamic filter screens understandable. Rule of thumb: specifications for filters, explicit queries for shape.$body$, $code$public static Specification<Order> hasStatus(Status status) {
    return (root, query, cb) -> status == null
            ? null
            : cb.equal(root.get("status"), status);
}

repository.findAll(hasStatus(Status.OPEN).and(minTotalCents(500)));$code$),
    ('jpa-criteria-and-specifications', 3, 'Fetch graphs and paging pitfalls', $body$Fetching associations in Criteria uses root.fetch, which is not a join you can reference in predicates; the same association accessed twice creates a second join and duplicate rows. Pairing that fetch with setFirstResult and setMaxResults can force in-memory pagination, and fetching two collections at once throws for bags. Counts for page results need their own query with the same predicates but without fetches. Rule of thumb: filters and fetch plans are separate concerns, expressed separately and verified against the generated SQL.$body$, $code$CriteriaBuilder cb = entityManager.getCriteriaBuilder();
CriteriaQuery<Order> cq = cb.createQuery(Order.class);
Root<Order> root = cq.from(Order.class);
root.fetch("lines", JoinType.LEFT);
cq.select(root).distinct(true).where(predicate);
// keep pages small: fetch plus offset may paginate in memory
List<Order> orders = entityManager.createQuery(cq).getResultList();$code$)
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
    'hibernate-mapping-basics', 'hibernate-entity-lifecycle', 'jpa-persistence-context',
    'jpa-lazy-loading-pitfalls', 'n-plus-one-problem', 'jpa-fetch-strategies',
    'hibernate-batch-processing', 'jpa-locking-strategies', 'hibernate-second-level-cache',
    'jpa-pagination-strategies', 'hibernate-dirty-checking', 'jpa-vs-jdbc-tradeoffs',
    'hibernate-schema-generation', 'jpa-auditing-and-timestamps',
    'hibernate-statistics-and-tuning', 'jpa-criteria-and-specifications'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
