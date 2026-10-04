INSERT INTO learning_path (slug, title, description, sort_order, published)
VALUES
    ('mid-java-engineer', 'Mid-level Java Engineer', 'Build reliable services, APIs, and data flows with clear contracts.', 2, true),
    ('senior-java-engineer', 'Senior Java Engineer', 'Design resilient systems and reason about concurrency, persistence, and operations.', 3, true),
    ('lead-java-engineer', 'Lead Java Engineer', 'Shape team-level architecture, delivery practices, and technical direction.', 4, true),
    ('principal-java-engineer', 'Principal Java Engineer', 'Make organization-scale architecture and reliability decisions with measurable trade-offs.', 5, true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO skill (slug, name, description) VALUES
    ('java-syntax', 'Java syntax', 'Read and write core Java expressions, statements, and methods.'),
    ('control-flow', 'Control flow', 'Choose clear branching, loops, and early-return behavior.'),
    ('api-design', 'API design', 'Create stable, unsurprising contracts for callers.'),
    ('immutability', 'Immutability', 'Use immutable state to reduce accidental coupling and concurrency risk.'),
    ('http-rest', 'HTTP and REST', 'Model resources, status codes, and request/response contracts.'),
    ('sql-persistence', 'SQL and persistence', 'Model data constraints and correct transactional behavior.'),
    ('resilience', 'Resilience', 'Contain failures with timeouts, retries, and fallback policies.'),
    ('observability', 'Observability', 'Use logs, metrics, traces, and health signals to explain system behavior.'),
    ('architecture', 'Architecture', 'Decompose systems around ownership, boundaries, and quality attributes.'),
    ('distributed-systems', 'Distributed systems', 'Reason about partial failure, delivery semantics, and consistency.'),
    ('technical-leadership', 'Technical leadership', 'Align engineering decisions, teams, and delivery around outcomes.')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('java-types-and-variables', 'Java Types and Variables', 'Learn primitive and reference types, declarations, and safe conversions.', 'Junior', 18, true, 1),
    ('methods-and-control-flow', 'Methods and Control Flow', 'Break a small program into readable methods and explicit branches.', 'Junior', 22, true, 1),
    ('classes-and-encapsulation', 'Classes and Encapsulation', 'Model a small domain object while keeping invariants inside the class.', 'Junior', 25, true, 1),
    ('collections', 'Java Collections', 'Choose and use the right data structure, and understand the trade-offs.', 'Junior', 24, true, 1),
    ('exception-design', 'Designing Exceptions', 'Model failure clearly without hiding useful diagnostic context.', 'Junior', 18, true, 1),
    ('testing-boundaries', 'Testing System Boundaries', 'Write focused unit and integration tests for production services.', 'Junior', 32, true, 1),
    ('http-api-contracts', 'HTTP API Contracts', 'Design REST endpoints with predictable resources, status codes, and validation.', 'Mid', 30, true, 1),
    ('transactions-and-isolation', 'Transactions and Isolation', 'Use database transactions and constraints to protect business invariants.', 'Mid', 35, true, 1),
    ('dependency-injection', 'Dependency Injection in Practice', 'Separate application policy from infrastructure through explicit dependencies.', 'Mid', 28, true, 1),
    ('concurrency-primitives', 'Java Concurrency Primitives', 'Use atomic operations, locks, and executors with clear ownership.', 'Mid', 34, true, 1),
    ('service-resilience', 'Timeouts and Resilience', 'Prevent slow dependencies from consuming all of a service’s capacity.', 'Senior', 36, true, 1),
    ('event-driven-design', 'Event-Driven Design', 'Choose event boundaries and make consumers safe under duplicate delivery.', 'Senior', 38, true, 1),
    ('production-observability', 'Production Observability', 'Connect logs, metrics, traces, and alerts to user-visible service behavior.', 'Senior', 32, true, 1),
    ('service-boundaries', 'Choosing Service Boundaries', 'Split a system around data ownership and independent change rather than fashion.', 'Lead', 40, true, 1),
    ('engineering-decision-records', 'Engineering Decision Records', 'Record context, options, consequences, and revisit criteria for important choices.', 'Lead', 25, true, 1),
    ('safe-delivery-strategies', 'Safe Delivery Strategies', 'Reduce deployment risk with progressive rollout and evidence-based rollback.', 'Lead', 32, true, 1),
    ('architecture-quality-attributes', 'Architecture Quality Attributes', 'Turn vague quality goals into measurable constraints and design choices.', 'Principal', 42, true, 1),
    ('multi-region-consistency', 'Multi-Region Consistency', 'Reason about consistency, failover, and ownership across regions.', 'Principal', 45, true, 1),
    ('platform-evolution', 'Evolving an Engineering Platform', 'Build paved roads that improve delivery without hiding operational ownership.', 'Principal', 38, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.example_code, s.sort_order
FROM (VALUES
    ('java-types-and-variables', 1, 'Primitive and reference values', 'Java primitives hold values such as an `int`; reference variables point to objects. Choose a type that communicates the domain and its valid range. Avoid narrowing conversions unless the range is checked first. `var` infers a local type but does not make Java dynamically typed.', E'int attempts = 3;\nString learnerName = "Mira";\nif (attempts > 0) {\n    System.out.println(learnerName);\n}'),
    ('java-types-and-variables', 2, 'Make conversions explicit', 'Integer division truncates the fractional part, and parsing external input can fail. Convert at the boundary and handle invalid values deliberately instead of letting surprising arithmetic leak into business rules.', E'int completed = 2;\nint total = 3;\ndouble fraction = (double) completed / total;\nSystem.out.println(fraction);'),
    ('methods-and-control-flow', 1, 'Give methods one job', 'A method should have a name and parameter list that make its behavior easy to call correctly. Keep validation close to the boundary and return early for invalid or terminal cases. Small methods are useful when they clarify a decision, not merely because they are short.', E'public static boolean canEnroll(int seats, boolean active) {\n    if (!active || seats <= 0) {\n        return false;\n    }\n    return true;\n}'),
    ('methods-and-control-flow', 2, 'Choose readable branches', 'Use `switch` for a finite set of alternatives and loops for repeated work. Prefer explicit conditions over clever nested ternaries. Test boundary values such as zero, empty input, and the last valid index.', E'string status = switch (attempts) {\n    case 0 -> "complete";\n    case 1 -> "last attempt";\n    default -> "in progress";\n};'),
    ('classes-and-encapsulation', 1, 'Protect an invariant', 'Encapsulation means an object owns the rules that keep its state valid. Do not expose mutable fields and expect every caller to remember the rules. Validate in the constructor and expose operations that describe intent.', E'public final class SeatCounter {\n    private int remaining;\n\n    public SeatCounter(int capacity) {\n        if (capacity < 0) throw new IllegalArgumentException();\n        this.remaining = capacity;\n    }\n}'),
    ('classes-and-encapsulation', 2, 'Prefer composition', 'Represent a concept with the smallest set of fields and operations that express its behavior. Composition lets a class collaborate with focused objects without inheriting unrelated behavior. Immutable value records are useful when identity and behavior are simple.', E'public record Money(long cents, String currency) {\n    public Money {\n        if (cents < 0) throw new IllegalArgumentException("cents");\n        if (currency == null || currency.isBlank()) throw new IllegalArgumentException("currency");\n    }\n}'),
    ('collections', 1, 'Select by access pattern', 'Use a `List` when order and positional access matter, a `Set` for uniqueness, and a `Map` for key lookup. A `HashMap` usually provides expected constant-time lookup, but mutable keys and inconsistent `equals`/`hashCode` break lookups. Preserve ordering explicitly when it is part of the contract.', E'Map<String, Integer> scores = new HashMap<>();\nscores.put("Alice", 100);\nscores.put("Bob", 80);\nSet<String> learners = new HashSet<>(scores.keySet());'),
    ('collections', 2, 'Do not leak mutable collections', 'A caller that receives an internal mutable collection can bypass your invariants. Copy input collections and return immutable views or copies when ownership should remain private. Choose concurrent collections only when their exact concurrency guarantees match the operation.', E'private final List<String> tags;\n\npublic Example(List<String> tags) {\n    this.tags = List.copyOf(tags);\n}\n\npublic List<String> tags() {\n    return tags;\n}'),
    ('exception-design', 1, 'Make failure meaningful', 'Throw an exception when an operation cannot satisfy its contract. Use argument exceptions for invalid caller input and domain exceptions for meaningful business outcomes. Avoid broad catches that turn failures into success-shaped defaults.', E'if (quantity <= 0) {\n    throw new IllegalArgumentException("quantity must be positive");\n}\nif (inventory < quantity) {\n    throw new InsufficientInventoryException(itemId);\n}'),
    ('exception-design', 2, 'Preserve causal context', 'Translate exceptions only at a boundary where the abstraction changes. Keep the original cause so logs and diagnostics retain the reason. Catch only failures that the current layer can handle, retry, or report more usefully.', E'try {\n    gateway.capture(payment);\n} catch (GatewayUnavailableException ex) {\n    throw new CheckoutException("Payment could not be completed", ex);\n}'),
    ('testing-boundaries', 1, 'Test observable behavior', 'A unit test should state a behavior and assert an observable result. Use descriptive names, arrange only the data the scenario needs, and avoid assertions about private implementation details. Cover the normal case, a boundary, and a meaningful failure.', E'@Test\nvoid rejectsAnUnknownPayment() {\n    assertThrows(PaymentNotFoundException.class,\n        () -> service.capture("missing-id"));\n}'),
    ('testing-boundaries', 2, 'Test the right boundary', 'Unit tests isolate business rules; integration tests verify framework wiring, persistence, and serialization. Keep external services behind replaceable boundaries, but retain a small number of tests that exercise the actual database or HTTP contract.', E'@Test\nvoid savesAndReadsTheSameOrder() {\n    repository.save(order);\n    assertThat(repository.findById(order.id())).contains(order);\n}'),
    ('http-api-contracts', 1, 'Model resources and status codes', 'A REST API should make resource identity and state transitions explicit. Use `201 Created` when a resource is created, `204 No Content` when no body is useful, `404` for a missing resource, and `409` for a conflicting state. Keep error shapes stable and document them.', E'@PostMapping("/orders")\nResponseEntity<OrderView> create(@Valid @RequestBody CreateOrder request) {\n    OrderView order = service.create(request);\n    return ResponseEntity.created(URI.create("/orders/" + order.id())).body(order);\n}'),
    ('http-api-contracts', 2, 'Validate at the boundary', 'Validate syntax and size before invoking domain work, then enforce business invariants in the domain or service. Do not trust client-provided ownership or role fields. Version contracts deliberately and add tests for malformed requests and status codes.', E'public record CreateOrder(\n    @NotBlank @Size(max = 80) String reference,\n    @Positive int itemCount\n) {}'),
    ('transactions-and-isolation', 1, 'Protect invariants in the database', 'A transaction groups related reads and writes, but application-level check-then-act logic can still race. Use unique constraints, conditional updates, or row locks to make the invariant atomic at the database boundary. Treat constraints as a final line of defense.', E'UPDATE inventory\nSET available = available - :quantity\nWHERE sku = :sku AND available >= :quantity;'),
    ('transactions-and-isolation', 2, 'Pick isolation intentionally', 'Higher isolation can prevent anomalies but may increase contention and retries. Understand which anomaly matters, keep transactions short, and handle serialization failures when the chosen database level can raise them. Never call a slow remote service while holding a database lock.', E'@Transactional\npublic void reserve(String sku, int quantity) {\n    if (repository.reserveIfAvailable(sku, quantity) != 1) {\n        throw new InsufficientInventoryException(sku);\n    }\n}'),
    ('dependency-injection', 1, 'Inject collaborators explicitly', 'Constructor injection makes required dependencies visible and objects easier to test. Keep business policy in application services and infrastructure details behind small interfaces. Avoid service locators and static mutable state, which hide coupling.', E'@Service\npublic class CheckoutService {\n    private final PaymentGateway gateway;\n\n    public CheckoutService(PaymentGateway gateway) {\n        this.gateway = gateway;\n    }\n}'),
    ('dependency-injection', 2, 'Keep configuration at the edge', 'Wire implementations in the composition root and pass typed configuration rather than reading environment variables throughout domain code. A test can then provide a deterministic implementation without changing production policy.', E'@ConfigurationProperties("checkout")\npublic record CheckoutProperties(Duration timeout, int maxAttempts) {}'),
    ('concurrency-primitives', 1, 'Make state transitions atomic', 'A sequence of a read followed by a write is not automatically atomic, even if each field access is safe. Use compare-and-set for a single state transition, a lock for a compound invariant, or a database transaction when state is shared across processes.', E'private final AtomicBoolean processed = new AtomicBoolean();\n\npublic boolean processPayment() {\n    return processed.compareAndSet(false, true);\n}'),
    ('concurrency-primitives', 2, 'Bound concurrent work', 'Executors separate task submission from execution, but an unbounded queue can convert overload into memory exhaustion and latency. Bound worker counts and queues, define rejection behavior, and propagate deadlines and cancellation to work that is no longer useful.', E'var executor = new ThreadPoolExecutor(\n    4, 4, 0, TimeUnit.SECONDS,\n    new ArrayBlockingQueue<>(100),\n    new ThreadPoolExecutor.AbortPolicy());'),
    ('service-resilience', 1, 'Set timeouts before retries', 'Every network call needs a deadline so a stalled dependency cannot pin threads forever. Retries multiply load and should be bounded, limited to transient failures, and delayed with jitter. A retry is safe only when the operation is idempotent or protected by an idempotency key.', E'if (deadline.isExpired()) {\n    throw new DependencyTimeoutException("Inventory deadline exceeded");\n}\nreturn inventoryClient.fetch(request, deadline.remaining());'),
    ('service-resilience', 2, 'Use bulkheads and circuit breakers carefully', 'Bulkheads cap the resources consumed by one dependency. Circuit breakers can stop calls during sustained failure, but they need sensible open, half-open, and recovery behavior. Emit metrics for rejected, retried, timed-out, and successful calls so policies can be tuned from evidence.', E'BulkheadConfig config = BulkheadConfig.custom()\n    .maxConcurrentCalls(20)\n    .maxWaitDuration(Duration.ZERO)\n    .build();'),
    ('event-driven-design', 1, 'Make consumers idempotent', 'Message brokers commonly deliver a message more than once. Record a stable event identifier and make the state change and deduplication record atomic. Acknowledge only after durable processing, and make poison-message handling observable.', E'@Transactional\npublic void handle(OrderPlaced event) {\n    if (processedEvents.insertIfAbsent(event.id())) {\n        inventory.reserve(event.orderId());\n    }\n}'),
    ('event-driven-design', 2, 'Use an outbox for reliable publication', 'A database commit and broker publish are separate operations; one can succeed while the other fails. Write an outbox row in the same transaction as the business change, then publish it asynchronously and mark it delivered. Consumers still need idempotency.', E'@Transactional\npublic void placeOrder(Order order) {\n    orders.insert(order);\n    outbox.insert(new OrderPlaced(order.id()));\n}'),
    ('production-observability', 1, 'Instrument outcomes, not noise', 'Metrics should count requests, failures, latency, and saturation with bounded-cardinality labels. Logs add event context but should not contain credentials or unbounded user input. Traces show where a request spent time across service boundaries.', E'Counter.builder("checkout.failures")\n    .tag("reason", reason.code())\n    .register(meterRegistry)\n    .increment();'),
    ('production-observability', 2, 'Alert on user impact', 'An alert should indicate a user-visible symptom or a quickly approaching resource limit, with an owner and a useful runbook. Prefer a small set of service-level indicators and objectives over pages for every internal exception.', E'// Example indicator: successful requests / all eligible requests\n// Evaluate over a rolling window and alert on sustained budget burn.'),
    ('service-boundaries', 1, 'Align boundaries with ownership', 'A service boundary should encapsulate data and decisions that change together. Splitting by technical layer creates remote calls without creating independent ownership. Start with a modular design and extract a service when independent scaling, security, or delivery needs justify the cost.', E'interface Fulfillment {\n    Shipment plan(Order order);\n}\n\nfinal class CheckoutService {\n    private final Fulfillment fulfillment;\n}'),
    ('service-boundaries', 2, 'Make contracts support change', 'A durable boundary has explicit ownership, compatibility rules, and failure semantics. Define what callers may assume, how changes are rolled out, and who operates each dependency. Shared databases often undermine a nominal service boundary.', E'// Document: owner, API, data owner,\n// availability target, timeout, and deprecation policy.'),
    ('engineering-decision-records', 1, 'Capture the decision context', 'A decision record preserves why a choice was made, not just what was chosen. State the context and constraints, list realistic alternatives, and explain consequences. Include dissent and uncertainty when they affect future choices.', E'# Decision\nUse an outbox for order events.\n\n## Context\nOrder persistence and broker publication must not diverge.'),
    ('engineering-decision-records', 2, 'Make decisions revisitable', 'Record a status, date, owners, and signals that would trigger a revisit. Avoid treating a decision as permanent policy when it is a context-specific trade-off. Link follow-up work so the record remains connected to delivery.', E'## Revisit when\n- Event throughput exceeds the current relay capacity.\n- The team adopts a broker with transactional integration.'),
    ('safe-delivery-strategies', 1, 'Reduce blast radius', 'A canary or phased rollout sends a small portion of traffic to a new version before expanding. Define guardrails first, compare against a baseline, and stop automatically when user-impacting indicators regress. A rollout without a rollback path is not progressive delivery.', E'if (errorRate > baselineErrorRate + allowedDelta) {\n    haltRollout();\n    rollback();\n}'),
    ('safe-delivery-strategies', 2, 'Separate deploy from activation', 'Feature flags can decouple deployment from exposure, but stale flags add complexity and security risk. Give each flag an owner and removal date. Database changes should use expand-migrate-contract steps so old and new versions can overlap safely.', E'// 1. Add backward-compatible column.\n// 2. Dual-write and backfill.\n// 3. Switch reads, then remove old field later.'),
    ('architecture-quality-attributes', 1, 'Turn quality goals into scenarios', '“Fast” or “reliable” is not testable until the workload, measurement, and threshold are explicit. Write scenarios with a stimulus, operating context, expected response, and measurable response limit. Rank scenarios by business impact.', E'// At 2x normal peak traffic, 99% of reads\n// complete within 200 ms without data loss.'),
    ('architecture-quality-attributes', 2, 'Choose constraints from evidence', 'Architecture is a set of trade-offs among latency, availability, cost, security, and change speed. Prototype the riskiest assumption, measure under representative load, and document the decision and its revisit trigger. Avoid optimizing attributes no stakeholder needs.', E'Record the workload, benchmark, cost model,\noperational owner, and failure behavior.'),
    ('multi-region-consistency', 1, 'Choose data ownership first', 'Multi-region active-active writes require a conflict policy and a clear owner for each piece of state. Asynchronous replication lowers write latency but can expose stale reads and lose recent writes during failover. State the consistency guarantee at the API boundary.', E'// Route writes for an account to one home region;\n// replicate changes and expose replication lag.'),
    ('multi-region-consistency', 2, 'Design failover as a tested procedure', 'Failover requires fencing the old writer, promoting a consistent replica, routing traffic, and validating recovery. Define RPO and RTO, rehearse failure scenarios, and measure replication lag. DNS changes alone do not prevent split brain.', E'if (replicaLag > allowedRpo) {\n    blockAutomaticPromotion();\n    requireOperatorReview();\n}'),
    ('platform-evolution', 1, 'Build a paved road with escape hatches', 'A platform should make the safe and common path easier while preserving explicit escape hatches for legitimate edge cases. Measure adoption, lead time, failure rate, and developer feedback. A platform feature without an owner becomes another dependency to maintain.', E'interface ServiceTemplate {\n    BuildPlan create(ServiceRequest request);\n    // Expose supported extension points explicitly.\n}'),
    ('platform-evolution', 2, 'Evolve through compatibility', 'Platform changes affect many teams, so use staged adoption, published deprecation windows, and automated migration support. Keep ownership and support expectations clear. Retire a capability only after usage evidence and a safe migration path exist.', E'// Publish migration guide, compatibility window,\n// usage telemetry, and an accountable service owner.')
) AS s(slug, sort_order, title, body, example_code)
JOIN tutorial t ON t.slug = s.slug
WHERE NOT EXISTS (
    SELECT 1 FROM tutorial_section existing
    WHERE existing.tutorial_id = t.id AND existing.sort_order = s.sort_order
);

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id,
       t.id,
       COALESCE((
           SELECT max(existing.sort_order)
           FROM learning_path_tutorial existing
           WHERE existing.learning_path_id = lp.id
       ), 0) + row_number() OVER (PARTITION BY lp.id ORDER BY t.title)::integer
FROM tutorial t
JOIN learning_path lp
  ON lp.slug = CASE t.level
      WHEN 'Junior' THEN 'junior-java-developer'
      WHEN 'Mid' THEN 'mid-java-engineer'
      WHEN 'Senior' THEN 'senior-java-engineer'
      WHEN 'Lead' THEN 'lead-java-engineer'
      WHEN 'Principal' THEN 'principal-java-engineer'
  END
WHERE t.published = true
  AND NOT EXISTS (
      SELECT 1
      FROM learning_path_tutorial existing
      WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
  );

INSERT INTO challenge (slug, title, description, level, difficulty, category, starter_repository, published)
VALUES
    ('junior-temperature-converter', 'Build a Temperature Converter', 'Convert Celsius and Fahrenheit values while validating input and avoiding integer-rounding errors.', 'Junior', 'Junior', 'Java Fundamentals', jsonb_build_object('Main.java', E'public class Main {\n    public static double celsiusToFahrenheit(double celsius) {\n        // TODO: implement the conversion\n        return 0;\n    }\n}\n'), true),
    ('junior-word-frequency', 'Count Word Frequencies', 'Normalize a sentence and count each word using an appropriate collection.', 'Junior', 'Junior', 'Collections', jsonb_build_object('Main.java', E'import java.util.Map;\n\npublic class Main {\n    public static Map<String, Integer> countWords(String text) {\n        // TODO: normalize words and count them\n        return Map.of();\n    }\n}\n'), true),
    ('junior-safe-list-access', 'Make List Access Safe', 'Implement a safe lookup that handles null, empty, and out-of-range inputs without hiding valid values.', 'Junior', 'Junior', 'Defensive Programming', jsonb_build_object('Main.java', E'import java.util.List;\nimport java.util.Optional;\n\npublic class Main {\n    public static Optional<String> find(List<String> values, int index) {\n        // TODO: validate the list and index\n        return Optional.empty();\n    }\n}\n'), true),
    ('mid-order-validation', 'Validate an Order Request', 'Validate required fields and item quantities, returning clear validation errors for invalid requests.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'public class Main {\n    public record OrderRequest(String reference, int quantity) {}\n\n    public static boolean isValid(OrderRequest request) {\n        // TODO: enforce the request contract\n        return false;\n    }\n}\n'), true),
    ('mid-idempotent-retry', 'Make a Retried Operation Idempotent', 'Design an in-memory idempotency registry so repeated keys return the original result and conflicting requests are rejected.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', E'import java.util.Optional;\n\npublic class Main {\n    public static Optional<String> resultFor(String key) {\n        // TODO: track completed operations safely\n        return Optional.empty();\n    }\n}\n'), true),
    ('mid-bounded-task-queue', 'Build a Bounded Task Queue', 'Implement a bounded producer-consumer queue with clear full and empty behavior.', 'Mid', 'Mid', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.Optional;\n\npublic class Main {\n    public static Optional<Integer> poll() {\n        // TODO: implement bounded queue semantics\n        return Optional.empty();\n    }\n}\n'), true),
    ('senior-inventory-reservation', 'Reserve Inventory Atomically', 'Implement a reservation operation that never allows concurrent callers to reserve more units than remain.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', E'import java.util.concurrent.atomic.AtomicInteger;\n\npublic class Main {\n    private final AtomicInteger available = new AtomicInteger(10);\n\n    public boolean reserve(int quantity) {\n        // TODO: atomically reserve only available units\n        return false;\n    }\n}\n'), true),
    ('senior-resilient-client', 'Bound a Retrying Client', 'Implement a retry policy that honors an attempt cap, retries only transient failures, and stops at a deadline.', 'Senior', 'Senior', 'Resilience', jsonb_build_object('Main.java', E'public class Main {\n    public static int nextDelayMillis(int attempt, int baseDelay, int maxDelay) {\n        // TODO: calculate a bounded backoff delay\n        return 0;\n    }\n}\n'), true),
    ('lead-outbox-relay', 'Design an Outbox Relay', 'Implement relay bookkeeping that handles duplicate delivery, transient broker failures, and concurrent workers.', 'Lead', 'Lead', 'Distributed Systems', jsonb_build_object('Main.java', E'public class Main {\n    public static boolean shouldRetry(int attempt, boolean transientFailure) {\n        // TODO: define safe bounded retry behavior\n        return false;\n    }\n}\n'), true),
    ('lead-backward-compatible-api', 'Evolve an API Without Breaking Clients', 'Add a response field and migration behavior while preserving compatibility for older clients and mixed application versions.', 'Lead', 'Lead', 'API Design', jsonb_build_object('Main.java', E'public class Main {\n    public static String displayName(String givenName, String familyName) {\n        // TODO: support absent optional fields safely\n        return "";\n    }\n}\n'), true),
    ('lead-rate-limiter', 'Build a Fair Per-Tenant Rate Limiter', 'Design a bounded per-tenant limiter that rejects excess demand without unbounded memory growth.', 'Lead', 'Lead', 'Resilience', jsonb_build_object('Main.java', E'import java.time.Instant;\n\npublic class Main {\n    public static boolean allow(String tenant, Instant now) {\n        // TODO: implement bounded per-tenant admission\n        return false;\n    }\n}\n'), true),
    ('principal-tenant-isolation', 'Enforce Tenant Isolation', 'Review a data-access boundary and ensure every lookup is scoped to the authenticated tenant, including administrative paths.', 'Principal', 'Principal', 'Security Architecture', jsonb_build_object('Main.java', E'public class Main {\n    public static boolean mayRead(String principalTenant, String recordTenant) {\n        // TODO: enforce explicit tenant ownership\n        return false;\n    }\n}\n'), true),
    ('principal-failover-policy', 'Define a Safe Failover Policy', 'Implement a promotion decision that respects replication lag and prevents two regions from accepting writes.', 'Principal', 'Principal', 'Distributed Systems', jsonb_build_object('Main.java', E'public class Main {\n    public static boolean mayPromote(long lagMillis, long maxLagMillis, boolean oldWriterFenced) {\n        // TODO: require safe lag and writer fencing\n        return false;\n    }\n}\n'), true),
    ('principal-capacity-planner', 'Plan Capacity Under Load', 'Calculate safe worker capacity from arrival rate, service time, and a utilization target; reject invalid assumptions.', 'Principal', 'Principal', 'Architecture', jsonb_build_object('Main.java', E'public class Main {\n    public static int requiredWorkers(double requestsPerSecond, double secondsPerRequest, double targetUtilization) {\n        // TODO: calculate capacity with a safety margin\n        return 0;\n    }\n}\n'), true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO challenge_skill (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
    ('junior-temperature-converter', 'java-fundamentals'),
    ('junior-temperature-converter', 'java-syntax'),
    ('junior-word-frequency', 'collections'),
    ('junior-word-frequency', 'java-fundamentals'),
    ('junior-safe-list-access', 'control-flow'),
    ('junior-safe-list-access', 'exceptions'),
    ('mid-order-validation', 'api-design'),
    ('mid-order-validation', 'testing'),
    ('mid-idempotent-retry', 'api-design'),
    ('mid-idempotent-retry', 'concurrency'),
    ('mid-bounded-task-queue', 'concurrency'),
    ('mid-bounded-task-queue', 'testing'),
    ('payment-race-condition', 'concurrency'),
    ('payment-race-condition', 'testing'),
    ('senior-inventory-reservation', 'concurrency'),
    ('senior-inventory-reservation', 'sql-persistence'),
    ('senior-resilient-client', 'resilience'),
    ('senior-resilient-client', 'testing'),
    ('lead-outbox-relay', 'distributed-systems'),
    ('lead-outbox-relay', 'sql-persistence'),
    ('lead-backward-compatible-api', 'api-design'),
    ('lead-backward-compatible-api', 'technical-leadership'),
    ('lead-rate-limiter', 'resilience'),
    ('lead-rate-limiter', 'architecture'),
    ('principal-tenant-isolation', 'architecture'),
    ('principal-tenant-isolation', 'api-design'),
    ('principal-failover-policy', 'distributed-systems'),
    ('principal-failover-policy', 'resilience'),
    ('principal-capacity-planner', 'architecture'),
    ('principal-capacity-planner', 'observability')
) AS wanted(challenge_slug, skill_slug)
JOIN challenge c ON c.slug = wanted.challenge_slug
JOIN skill s ON s.slug = wanted.skill_slug
ON CONFLICT DO NOTHING;

INSERT INTO challenge_requirement (challenge_id, description, sort_order)
SELECT c.id, requirement.description, requirement.sort_order
FROM (VALUES
    ('junior-temperature-converter', 'Return the mathematically correct conversion for positive and negative temperatures.', 1),
    ('junior-temperature-converter', 'Use floating-point arithmetic so fractional temperatures are preserved.', 2),
    ('junior-temperature-converter', 'Reject values that are not finite.', 3),
    ('junior-word-frequency', 'Treat words case-insensitively and ignore surrounding punctuation.', 1),
    ('junior-word-frequency', 'Return the correct count for every normalized word.', 2),
    ('junior-word-frequency', 'Handle null, blank, and punctuation-only input safely.', 3),
    ('junior-safe-list-access', 'Return an empty result for null lists and invalid indices.', 1),
    ('junior-safe-list-access', 'Return the selected value when the index is valid.', 2),
    ('junior-safe-list-access', 'Do not mutate the supplied list.', 3),
    ('mid-order-validation', 'Require a non-blank reference and a positive quantity.', 1),
    ('mid-order-validation', 'Reject null requests without throwing an accidental null-pointer exception.', 2),
    ('mid-order-validation', 'Keep validation behavior deterministic and easy to test.', 3),
    ('mid-idempotent-retry', 'A repeated key with the same request must not perform the operation twice.', 1),
    ('mid-idempotent-retry', 'A key reused for a different request must be reported as a conflict.', 2),
    ('mid-idempotent-retry', 'Concurrent requests using the same key must be safe.', 3),
    ('mid-bounded-task-queue', 'Never exceed the configured capacity.', 1),
    ('mid-bounded-task-queue', 'Preserve FIFO order for accepted items.', 2),
    ('mid-bounded-task-queue', 'Define non-blocking behavior for full and empty states.', 3),
    ('payment-race-condition', 'A payment must only be processed once.', 1),
    ('payment-race-condition', 'Concurrent requests must be safe.', 2),
    ('payment-race-condition', 'Preserve existing API behavior and add appropriate tests.', 3),
    ('senior-inventory-reservation', 'Reject non-positive quantities.', 1),
    ('senior-inventory-reservation', 'Never reserve more units than are available.', 2),
    ('senior-inventory-reservation', 'Remain correct with concurrent callers.', 3),
    ('senior-resilient-client', 'Retry only transient failures and never exceed the attempt limit.', 1),
    ('senior-resilient-client', 'Stop retrying when the deadline expires.', 2),
    ('senior-resilient-client', 'Keep backoff bounded and handle arithmetic overflow.', 3),
    ('lead-outbox-relay', 'Do not mark an event delivered before the broker confirms publication.', 1),
    ('lead-outbox-relay', 'Make duplicate delivery safe for downstream consumers.', 2),
    ('lead-outbox-relay', 'Bound retries and provide an observable terminal failure path.', 3),
    ('lead-backward-compatible-api', 'Preserve the meaning of existing response fields.', 1),
    ('lead-backward-compatible-api', 'Handle missing optional data without breaking old clients.', 2),
    ('lead-backward-compatible-api', 'Define a migration and deprecation strategy.', 3),
    ('lead-rate-limiter', 'Enforce a per-tenant request budget over the configured window.', 1),
    ('lead-rate-limiter', 'Prevent one tenant from consuming another tenant’s allowance.', 2),
    ('lead-rate-limiter', 'Bound memory usage and define behavior at capacity.', 3),
    ('principal-tenant-isolation', 'Authorize every record access against the authenticated tenant.', 1),
    ('principal-tenant-isolation', 'Fail closed when tenant context is missing or mismatched.', 2),
    ('principal-tenant-isolation', 'Keep privileged access explicit, audited, and narrowly scoped.', 3),
    ('principal-failover-policy', 'Require the old writer to be fenced before promoting a new writer.', 1),
    ('principal-failover-policy', 'Reject replicas whose lag exceeds the recovery-point objective.', 2),
    ('principal-failover-policy', 'Make unavailable or invalid telemetry fail closed.', 3),
    ('principal-capacity-planner', 'Validate positive arrival rate and service time plus utilization in (0, 1).', 1),
    ('principal-capacity-planner', 'Round worker demand up so capacity meets the requested workload.', 2),
    ('principal-capacity-planner', 'Reject non-finite values and integer overflow.', 3)
) AS requirement(challenge_slug, description, sort_order)
JOIN challenge c ON c.slug = requirement.challenge_slug
WHERE NOT EXISTS (
    SELECT 1 FROM challenge_requirement existing
    WHERE existing.challenge_id = c.id AND existing.sort_order = requirement.sort_order
);
