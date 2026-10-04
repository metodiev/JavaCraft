INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('strings-and-text', 'Working with Strings and Text', 'Parse, normalize, and format text while keeping Unicode and input-boundary behavior explicit.', 'Junior', 24, true, 1),
    ('enums-and-records', 'Enums and Records for Domain Models', 'Represent finite states and immutable data with types that make invalid states harder to express.', 'Junior', 22, true, 1),
    ('dates-and-time', 'Dates, Time, and Time Zones', 'Choose the correct Java time types and avoid ambiguous timestamps and daylight-saving bugs.', 'Junior', 28, true, 1),
    ('pagination-and-filtering', 'Pagination and Filtering', 'Build predictable page boundaries, stable ordering, and validated filter contracts.', 'Mid', 30, true, 1),
    ('caching-strategies', 'Caching Strategies and Expiration', 'Choose cache keys, expiration, and invalidation behavior that preserve correctness.', 'Mid', 32, true, 1),
    ('contract-testing', 'Contract Testing for Service APIs', 'Verify request and response compatibility at service boundaries without coupling tests to internals.', 'Mid', 30, true, 1),
    ('profiling-java-services', 'Profiling Java Services', 'Use measurements to find CPU, allocation, and latency bottlenecks before changing production code.', 'Senior', 38, true, 1),
    ('cache-consistency', 'Cache Consistency Under Load', 'Reason about stale reads, stampedes, and invalidation when multiple callers share cached state.', 'Senior', 40, true, 1),
    ('database-contention', 'Diagnosing Database Contention', 'Understand lock waits, transaction duration, and safe retry behavior under contention.', 'Senior', 38, true, 1),
    ('platform-api-design', 'Designing Platform APIs', 'Create reusable platform contracts with clear ownership, compatibility, and operational limits.', 'Lead', 42, true, 1),
    ('migration-strategies', 'Coordinating Safe Migrations', 'Plan expand-and-contract changes that work while old and new application versions overlap.', 'Lead', 40, true, 1),
    ('service-level-objectives', 'Service-Level Objectives in Practice', 'Translate user expectations into measurable SLIs, SLOs, and actionable error budgets.', 'Lead', 38, true, 1),
    ('data-governance', 'Data Governance Across Systems', 'Set practical ownership, retention, residency, and access rules for distributed data.', 'Principal', 42, true, 1),
    ('consistency-and-availability', 'Consistency and Availability Trade-offs', 'Choose consistency guarantees by workflow and failure mode rather than applying one policy everywhere.', 'Principal', 45, true, 1),
    ('architecture-economics', 'Architecture Economics and Capacity', 'Compare architecture options using lifecycle cost, capacity limits, and the value of reversible decisions.', 'Principal', 42, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('strings-and-text', 1, 'Normalize at a deliberate boundary', $body$Text received from files, HTTP requests, or users is input, not trusted domain data. Decide whether whitespace, case, punctuation, and Unicode normalization are significant before comparing or storing values. Use `Locale.ROOT` for locale-independent identifiers; user-facing language conversion may need a locale supplied by the user.$body$, $code$String key = raw.strip().toLowerCase(Locale.ROOT);
if (key.isEmpty()) {
    throw new IllegalArgumentException("key must not be blank");
}$code$),
    ('strings-and-text', 2, 'Build output without quadratic copying', $body$Repeated string concatenation inside a loop can repeatedly copy the accumulated text. A `StringBuilder` is appropriate for incremental assembly. For parsing, define what malformed input means and report it explicitly rather than returning a plausible but incorrect default.$body$, $code$StringBuilder csv = new StringBuilder();
for (String field : fields) {
    if (!csv.isEmpty()) csv.append(',');
    csv.append(field);
}
String result = csv.toString();$code$),
    ('enums-and-records', 1, 'Use enums for closed sets', $body$An enum represents a finite set of known choices and gives callers compile-time checking. Avoid persisting `ordinal()`: reordering constants would silently change stored meaning. Persist a stable explicit code when a value crosses a durable or external boundary.$body$, $code$enum JobState {
    QUEUED("queued"), RUNNING("running"), COMPLETE("complete");

    private final String code;
    JobState(String code) { this.code = code; }
    String code() { return code; }
}$code$),
    ('enums-and-records', 2, 'Keep value objects immutable', $body$Records are concise carriers for values, but a record is only shallowly immutable. Copy mutable collections on construction and validate invariants there. Prefer a named operation or factory when construction rules are more meaningful than a large public parameter list.$body$, $code$record Batch(String id, List<String> itemIds) {
    Batch {
        if (id == null || id.isBlank()) throw new IllegalArgumentException("id");
        itemIds = List.copyOf(itemIds);
    }
}$code$),
    ('dates-and-time', 1, 'Use types that match the meaning', $body$Use `Instant` for a unique point on the UTC timeline, `LocalDate` for a calendar date without a time zone, and `ZonedDateTime` when local wall-clock rules matter. A `LocalDateTime` alone does not identify one global instant and should not be used as a substitute for an event timestamp.$body$, $code$Instant receivedAt = Instant.now();
LocalDate billingDate = LocalDate.of(2026, 10, 1);
ZonedDateTime storeOpening = billingDate.atTime(9, 0)
    .atZone(ZoneId.of("Europe/Sofia"));$code$),
    ('dates-and-time', 2, 'Make parsing and durations explicit', $body$Parse external date text with an explicit format and handle invalid input at the boundary. Use `Duration` for elapsed time and `Period` for calendar-based amounts. Daylight-saving transitions mean that adding a day in a time zone is not always the same as adding 24 elapsed hours.$body$, $code$DateTimeFormatter format = DateTimeFormatter.ISO_LOCAL_DATE;
LocalDate requested = LocalDate.parse(input, format);
Instant expiresAt = clock.instant().plus(Duration.ofMinutes(15));$code$),
    ('pagination-and-filtering', 1, 'Define page boundaries and limits', $body$An API should define whether page indices are zero- or one-based, the maximum page size, and what happens for invalid values. Clamp or reject oversized requests deliberately; never let an untrusted page size control an unbounded database read.$body$, $code$int page = Math.max(0, requestedPage);
int size = Math.min(Math.max(1, requestedSize), 100);
long offset = (long) page * size;$code$),
    ('pagination-and-filtering', 2, 'Use stable ordering', $body$Pagination over a changing dataset needs a deterministic order. Add a unique tie-breaker to sort fields or prefer a cursor based on the last seen key. Offset pagination can skip or repeat records as rows are inserted; document that trade-off for the use case.$body$, $code$SELECT id, created_at, status
FROM job
WHERE status = :status
ORDER BY created_at DESC, id DESC
LIMIT :limit OFFSET :offset;$code$),
    ('caching-strategies', 1, 'Treat cache keys as part of the contract', $body$A cache key must include every input that affects the result, including tenant, locale, authorization scope, or version where applicable. A key collision across security boundaries can disclose one caller’s data to another. Normalize keys consistently and bound their size.$body$, $code$record ProfileKey(String tenantId, String userId, String locale) {}
ProfileKey key = new ProfileKey(tenantId, userId, locale);$code$),
    ('caching-strategies', 2, 'Choose expiration and invalidation deliberately', $body$Time-to-live bounds staleness but does not make a cache correct by itself. Invalidate or version entries when writes change their source data, and decide whether a cache miss may call a slow dependency. Add jitter to large synchronized expirations to reduce refresh bursts.$body$, $code$Duration ttlWithJitter(Duration ttl, long jitterSeconds) {
    long extra = ThreadLocalRandom.current().nextLong(jitterSeconds + 1);
    return ttl.plusSeconds(extra);
}$code$),
    ('contract-testing', 1, 'Assert the public contract', $body$A contract test checks externally visible request and response behavior: field names, required values, status codes, and error shapes. It should not assert private method calls or database implementation details. Include representative valid input and boundary failures.$body$, $code$mockMvc.perform(post("/orders")
        .contentType(MediaType.APPLICATION_JSON)
        .content("""
            {"reference":"A-17","quantity":2}
            """))
    .andExpect(status().isCreated())
    .andExpect(jsonPath("$.reference").value("A-17"));$code$),
    ('contract-testing', 2, 'Keep compatibility evidence repeatable', $body$Provider and consumer checks should be runnable in CI and should identify which contract version was verified. A consumer expectation is not automatically correct: review whether it captures a supported guarantee or accidentally freezes an implementation detail.$body$, $code$assertThat(response.statusCode()).isEqualTo(400);
assertThat(response.body())
    .contains("\"error\":\"invalid_quantity\"");$code$),
    ('profiling-java-services', 1, 'Establish a reproducible baseline', $body$Before optimizing, record workload, environment, warm-up, and representative input. Measure throughput and latency distributions rather than relying only on averages. Compare like-for-like runs and keep the baseline so a claimed improvement can be reproduced.$body$, $code$long started = System.nanoTime();
service.handle(representativeRequest);
long elapsedNanos = System.nanoTime() - started;
System.out.println(Duration.ofNanos(elapsedNanos));$code$),
    ('profiling-java-services', 2, 'Follow evidence to the constrained resource', $body$CPU profiles show where execution time is spent; allocation profiles reveal churn and garbage-collection pressure; thread and database metrics expose waiting. Optimize the dominant measured cost, then repeat the workload. Avoid retaining high-cardinality request data in metrics or diagnostic logs.$body$, $code$Timer.Sample sample = Timer.start(registry);
try {
    return service.handle(request);
} finally {
    sample.stop(registry.timer("service.handle"));
}$code$),
    ('cache-consistency', 1, 'Choose a consistency contract', $body$Document whether a cached read may be stale, for how long, and after which writes it must become fresh. Read-your-writes and monotonic reads may matter even when global strong consistency is unnecessary. Select the weakest guarantee that safely satisfies the workflow.$body$, $code$long version = store.currentVersion(key);
CacheEntry entry = cache.get(key);
if (entry == null || entry.version() < version) {
    entry = refresh(key, version);
}$code$),
    ('cache-consistency', 2, 'Control refresh stampedes', $body$When an entry expires, many callers can refresh it simultaneously. Use single-flight coordination, bounded refresh concurrency, or stale-while-revalidate when the contract permits. Always bound waits and retain a clear failure path when the origin is unavailable.$body$, $code$CompletableFuture<Value> refresh = inFlight.computeIfAbsent(
    key, ignored -> loadAsync(key).whenComplete((value, error) ->
        inFlight.remove(key)));
return refresh.orTimeout(2, TimeUnit.SECONDS);$code$),
    ('database-contention', 1, 'Keep lock duration short', $body$A transaction holds locks for work that occurs between its first write or lock acquisition and commit. Avoid network calls, user interaction, and long CPU work in that interval. Inspect lock waits alongside query plans and transaction duration before changing isolation.$body$, $code$UPDATE inventory
SET available = available - :quantity
WHERE sku = :sku AND available >= :quantity;
-- Commit promptly; perform network work outside this transaction.$code$),
    ('database-contention', 2, 'Retry only well-defined transient failures', $body$Deadlocks and serialization failures may be retried when the whole transaction is safe to repeat. Use a bounded attempt count, backoff, and a request deadline. Do not retry every database exception or repeat external side effects without idempotency protection.$body$, $code$for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
        return runTransaction();
    } catch (TransientDataAccessException ex) {
        if (attempt == maxAttempts) throw ex;
        pause(backoff(attempt));
    }
}
throw new IllegalStateException("unreachable");$code$),
    ('platform-api-design', 1, 'Create reusable but bounded interfaces', $body$A platform API should expose the smallest stable capability that teams need, not every implementation option. Define ownership, authentication, quotas, versioning, and support expectations. Keep extension points explicit and avoid making optional configuration silently change security behavior.$body$, $code$interface ArtifactStore {
    StoredArtifact put(ArtifactId id, InputStream content, long maxBytes);
    Optional<StoredArtifact> find(ArtifactId id);
}$code$),
    ('platform-api-design', 2, 'Design for operational ownership', $body$Every shared capability needs service-level signals, an owner, and a safe failure mode. Document what callers should do when the platform is unavailable and how breaking changes are introduced. Prefer paved paths that are observable and reversible over opaque automation.$body$, $code$record PlatformLimits(int maxBytes, Duration requestTimeout) {
    PlatformLimits {
        if (maxBytes <= 0 || requestTimeout.isNegative()
                || requestTimeout.isZero()) {
            throw new IllegalArgumentException("limits must be positive");
        }
    }
}$code$),
    ('migration-strategies', 1, 'Expand before you contract', $body$For a rolling deployment, first add schema or API support that old and new versions can both use. Deploy compatible application code, backfill in bounded batches, verify evidence, and only then remove the old representation. A rollback plan must account for writes performed by the new version.$body$, $code$-- Expand: add a nullable column while old code still works.
ALTER TABLE customer ADD COLUMN display_name_v2 TEXT;
-- Backfill and validate before making it required.$code$),
    ('migration-strategies', 2, 'Make backfills restartable', $body$A production backfill should be resumable, rate-limited, observable, and safe to rerun. Track progress by a stable key and validate counts or checksums. Stop or slow the job when it harms foreground latency; never assume one enormous transaction is harmless.$body$, $code$UPDATE customer
SET display_name_v2 = display_name
WHERE id > :last_id AND id <= :batch_end
  AND display_name_v2 IS NULL;$code$),
    ('service-level-objectives', 1, 'Choose a user-centered indicator', $body$An SLI measures an aspect of service that users experience, such as successful requests within a latency threshold. Define numerator, denominator, window, and exclusions precisely. Instrumentation gaps and synthetic checks should be visible rather than counted as successful requests.$body$, $code$double availability = (double) successfulRequests
    / totalEligibleRequests;
boolean withinLatency = p95Millis <= latencyObjectiveMillis;$code$),
    ('service-level-objectives', 2, 'Use the error budget to guide action', $body$An SLO turns a reliability target into an error budget over a time window. A burn-rate alert detects budget consumption quickly enough to act. The response should be agreed in advance, proportionate, and focused on reducing user harm rather than treating the metric as a team score.$body$, $code$double budget = 1.0 - availabilityObjective;
double remainingBudget = budget - observedFailureRatio;
if (remainingBudget < 0) {
    pauseRiskyChanges();
}$code$),
    ('data-governance', 1, 'Assign ownership and classification', $body$Data needs an accountable owner, a defined purpose, and a classification that influences access and handling. Record authoritative sources and downstream consumers. Minimize copies because replicated sensitive data increases deletion, residency, and incident-response burden.$body$, $code$record DataAsset(String name, String owner, String classification,
                  Set<String> approvedPurposes) {
    DataAsset {
        approvedPurposes = Set.copyOf(approvedPurposes);
    }
}$code$),
    ('data-governance', 2, 'Make retention and deletion verifiable', $body$Retention rules should identify the event that starts the clock, the systems and backups in scope, and how deletion is verified. Legal holds and audit obligations need explicit precedence. A policy is incomplete if downstream replicas or exports are not included.$body$, $code$boolean mayRetain(Instant createdAt, Instant now, Duration policy) {
    return createdAt.plus(policy).isAfter(now);
}$code$),
    ('consistency-and-availability', 1, 'Match consistency to the business invariant', $body$A globally coordinated write may be necessary for a unique account balance, but unnecessary for a view counter. Identify which concurrent operations can conflict and what users may observe during a partition. State the invariant first; then choose storage and consistency mechanisms that enforce it.$body$, $code$record Transfer(String from, String to, long cents) {
    Transfer {
        if (from.equals(to) || cents <= 0) {
            throw new IllegalArgumentException("invalid transfer");
        }
    }
}$code$),
    ('consistency-and-availability', 2, 'Define behavior during partial failure', $body$A timeout does not prove a remote operation failed; it may have committed while its response was lost. Design retries around idempotency keys or operation identifiers. Decide when to reject, queue, or serve stale reads, and expose enough state for safe reconciliation.$body$, $code$record OperationResult(String operationId, State state) {
    enum State { ACCEPTED, COMPLETED, REJECTED, RECONCILIATION_REQUIRED }
}$code$),
    ('architecture-economics', 1, 'Compare lifecycle cost and constraints', $body$Estimate the workload and quality attributes that distinguish alternatives: traffic shape, data growth, recovery objectives, operational staffing, and vendor or migration costs. Use ranges and sensitivity analysis rather than false precision. Include the cost of failure and the cost of delaying a decision.$body$, $code$record OptionCost(String name, double monthlyRunCost,
                       double monthlyOperationsHours, double migrationCost) {}
// Compare total ownership cost over the expected decision horizon.$code$),
    ('architecture-economics', 2, 'Preserve options when uncertainty is high', $body$When evidence is weak, prefer a reversible experiment with a measurable decision threshold. Record the assumptions that would change the choice and the cost of switching later. Avoid premature platform-wide commitments when a contained pilot can answer the key question.$body$, $code$boolean expandPilot(double p95Millis, double errorRatio,
                    double latencyLimit, double errorLimit) {
    return p95Millis <= latencyLimit && errorRatio <= errorLimit;
}$code$)
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
    'strings-and-text', 'enums-and-records', 'dates-and-time',
    'pagination-and-filtering', 'caching-strategies', 'contract-testing',
    'profiling-java-services', 'cache-consistency', 'database-contention',
    'platform-api-design', 'migration-strategies', 'service-level-objectives',
    'data-governance', 'consistency-and-availability', 'architecture-economics'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);

INSERT INTO challenge (slug, title, description, level, difficulty, category, starter_repository, published)
VALUES
    ('junior-string-analyzer', 'Analyze a Sentence', 'Normalize a sentence and report its word count and longest word without failing on blank input.', 'Junior', 'Junior', 'Java Fundamentals', jsonb_build_object('Main.java', $code$public class Main {
    public static int wordCount(String text) {
        // TODO: define blank-input behavior and count words
        return 0;
    }
}
$code$), true),
    ('junior-grade-book', 'Summarize a Grade Book', 'Calculate a safe average from a collection of scores and handle an empty collection explicitly.', 'Junior', 'Junior', 'Collections', jsonb_build_object('Main.java', $code$import java.util.List;
import java.util.OptionalDouble;

public class Main {
    public static OptionalDouble average(List<Integer> scores) {
        // TODO: handle null and empty input deliberately
        return OptionalDouble.empty();
    }
}
$code$), true),
    ('junior-library-inventory', 'Track Library Copies', 'Model a small book inventory that cannot be checked out below zero or returned above its original capacity.', 'Junior', 'Junior', 'Object-Oriented Design', jsonb_build_object('Main.java', $code$public class Main {
    private final int capacity;
    private int available;

    public Main(int capacity) {
        // TODO: validate and initialize the inventory
        this.capacity = capacity;
    }
}
$code$), true),
    ('junior-date-range', 'Validate a Date Range', 'Check that a requested date range has valid endpoints and does not end before it begins.', 'Junior', 'Junior', 'Defensive Programming', jsonb_build_object('Main.java', $code$import java.time.LocalDate;

public class Main {
    public static boolean isValid(LocalDate start, LocalDate end) {
        // TODO: validate both endpoints and their order
        return false;
    }
}
$code$), true),
    ('junior-csv-summary', 'Summarize Simple CSV Rows', 'Parse simple comma-separated rows, trim fields, and reject malformed or empty values consistently.', 'Junior', 'Junior', 'Java Fundamentals', jsonb_build_object('Main.java', $code$import java.util.List;

public class Main {
    public static List<String> fields(String row) {
        // TODO: split, trim, and validate the row
        return List.of();
    }
}
$code$), true),
    ('mid-paginated-results', 'Build a Safe Page Request', 'Validate page and size parameters and calculate an offset without overflow or unbounded page sizes.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', $code$public class Main {
    public record PageRequest(int page, int size) {}

    public static long offset(PageRequest request) {
        // TODO: enforce bounds before calculating the offset
        return 0;
    }
}
$code$), true),
    ('mid-cache-expiration', 'Expire Cached Values', 'Implement a small cache entry policy that distinguishes fresh, expired, and invalid timestamps.', 'Mid', 'Mid', 'Resilience', jsonb_build_object('Main.java', $code$import java.time.Instant;

public class Main {
    public static boolean isFresh(Instant createdAt, Instant now, long ttlSeconds) {
        // TODO: validate inputs and check the expiry boundary
        return false;
    }
}
$code$), true),
    ('mid-resilient-batch', 'Process a Batch with Partial Failures', 'Process independent items without losing successful results, and report failures for retry or inspection.', 'Mid', 'Mid', 'API Design', jsonb_build_object('Main.java', $code$import java.util.List;

public class Main {
    public record BatchResult(List<String> succeeded, List<String> failed) {}

    public static BatchResult classify(List<String> itemIds) {
        // TODO: preserve every item and classify its outcome
        return new BatchResult(List.of(), List.of());
    }
}
$code$), true),
    ('mid-circuit-breaker', 'Implement a Circuit Breaker Decision', 'Define closed, open, and half-open transitions with a bounded recovery probe policy.', 'Mid', 'Mid', 'Resilience', jsonb_build_object('Main.java', $code$public class Main {
    public enum State { CLOSED, OPEN, HALF_OPEN }

    public static boolean mayCall(State state, int probesInFlight, int maxProbes) {
        // TODO: fail fast while open and cap recovery probes
        return false;
    }
}
$code$), true),
    ('mid-event-deduplicator', 'Deduplicate Delivered Events', 'Track event identifiers so duplicate deliveries do not repeat a side effect, while bounding retained identifiers.', 'Mid', 'Mid', 'Distributed Systems', jsonb_build_object('Main.java', $code$import java.util.Set;

public class Main {
    public static boolean firstDelivery(Set<String> processed, String eventId) {
        // TODO: define duplicate and invalid-id behavior
        return false;
    }
}
$code$), true),
    ('senior-bounded-executor', 'Bound Concurrent Work', 'Admit work only up to a configured concurrency limit and define how excess work is rejected.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', $code$import java.util.concurrent.atomic.AtomicInteger;

public class Main {
    private final AtomicInteger active = new AtomicInteger();

    public boolean tryAcquire(int limit) {
        // TODO: atomically admit work without exceeding the limit
        return false;
    }
}
$code$), true),
    ('senior-snapshot-consistency', 'Read a Consistent Snapshot', 'Combine values only when they belong to a compatible version, and report when a consistent snapshot is unavailable.', 'Senior', 'Senior', 'Distributed Systems', jsonb_build_object('Main.java', $code$public class Main {
    public record VersionedValue<T>(long version, T value) {}

    public static boolean sameSnapshot(VersionedValue<?> left, VersionedValue<?> right) {
        // TODO: reject missing or mismatched versions
        return false;
    }
}
$code$), true),
    ('senior-transaction-retry', 'Retry a Transaction Safely', 'Make a retry policy bounded by attempt count and deadline, and retry only classified transient failures.', 'Senior', 'Senior', 'SQL and Persistence', jsonb_build_object('Main.java', $code$import java.time.Duration;

public class Main {
    public static boolean shouldRetry(int attempt, int maxAttempts,
                                      Duration remaining, boolean transientFailure) {
        // TODO: validate limits and stop at the deadline
        return false;
    }
}
$code$), true),
    ('senior-cache-stampede', 'Coordinate a Cache Refresh', 'Allow one refresh per key at a time and ensure callers share the in-flight result.', 'Senior', 'Senior', 'Concurrency', jsonb_build_object('Main.java', $code$import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentMap;

public class Main {
    public static CompletableFuture<String> refresh(
            ConcurrentMap<String, CompletableFuture<String>> inFlight, String key) {
        // TODO: coordinate concurrent refreshes and clean up terminal entries
        return CompletableFuture.completedFuture("");
    }
}
$code$), true),
    ('senior-audit-pipeline', 'Preserve Audit Event Ordering', 'Assign a stable sequence to events for one aggregate and detect gaps without assuming global ordering.', 'Senior', 'Senior', 'Observability', jsonb_build_object('Main.java', $code$public class Main {
    public static boolean isNext(long previousSequence, long candidateSequence) {
        // TODO: reject duplicates, gaps, and invalid sequence values
        return false;
    }
}
$code$), true),
    ('lead-tenant-quota', 'Enforce Fair Tenant Quotas', 'Apply per-tenant limits without allowing one tenant to consume another tenant’s allocation.', 'Lead', 'Lead', 'Architecture', jsonb_build_object('Main.java', $code$public class Main {
    public static boolean mayAdmit(String tenant, int current,
                                   int tenantLimit, int globalLimit, int globalCurrent) {
        // TODO: enforce both local and global bounds
        return false;
    }
}
$code$), true),
    ('lead-schema-rollout', 'Plan a Compatible Schema Rollout', 'Decide whether a schema change is safe during mixed-version deployment and identify the required rollout phase.', 'Lead', 'Lead', 'SQL and Persistence', jsonb_build_object('Main.java', $code$public class Main {
    public enum Phase { EXPAND, BACKFILL, SWITCH_READS, CONTRACT }

    public static boolean mayRemoveOldField(Phase phase, boolean oldWritersRemain) {
        // TODO: prevent contract changes while old versions still write
        return false;
    }
}
$code$), true),
    ('lead-service-migration', 'Sequence a Service Migration', 'Design migration gates that retain rollback options until traffic and data ownership have been verified.', 'Lead', 'Lead', 'Distributed Systems', jsonb_build_object('Main.java', $code$public class Main {
    public static boolean mayCutOver(boolean dataVerified, boolean targetHealthy,
                                     boolean rollbackReady) {
        // TODO: require evidence before directing production traffic
        return false;
    }
}
$code$), true),
    ('lead-slo-budget', 'Calculate an Error Budget', 'Calculate remaining availability budget from a target and observed failure ratio, rejecting invalid measurements.', 'Lead', 'Lead', 'Observability', jsonb_build_object('Main.java', $code$public class Main {
    public static double remainingBudget(double targetAvailability, double observedFailureRatio) {
        // TODO: validate ratios and calculate remaining budget
        return 0;
    }
}
$code$), true),
    ('lead-queue-backpressure', 'Apply Queue Backpressure', 'Choose an admission response when queue depth or oldest-message age exceeds an operational limit.', 'Lead', 'Lead', 'Resilience', jsonb_build_object('Main.java', $code$public class Main {
    public static boolean mayAccept(int queueDepth, int maxDepth,
                                   long oldestAgeMillis, long maxAgeMillis) {
        // TODO: reject work when either bound is exceeded
        return false;
    }
}
$code$), true),
    ('principal-data-residency', 'Enforce Data Residency Policy', 'Route data only to permitted regions and fail closed when residency policy or destination is unknown.', 'Principal', 'Principal', 'Security Architecture', jsonb_build_object('Main.java', $code$import java.util.Set;

public class Main {
    public static boolean mayStore(String region, Set<String> permittedRegions) {
        // TODO: require a known destination explicitly allowed by policy
        return false;
    }
}
$code$), true),
    ('principal-consistency-model', 'Select a Consistency Policy', 'Choose a consistency requirement for an operation based on its invariant and whether bounded stale reads are acceptable.', 'Principal', 'Principal', 'Distributed Systems', jsonb_build_object('Main.java', $code$public class Main {
    public enum Consistency { STRONG, BOUNDED_STALENESS, EVENTUAL }

    public static Consistency forOperation(boolean invariantCritical,
                                           boolean staleReadsAcceptable) {
        // TODO: fail toward stronger guarantees when assumptions are unclear
        return Consistency.STRONG;
    }
}
$code$), true),
    ('principal-deprecation-plan', 'Gate an API Deprecation', 'Retire a version only after announced dates, supported-client adoption, and an emergency rollback path are verified.', 'Principal', 'Principal', 'API Design', jsonb_build_object('Main.java', $code$import java.time.Instant;

public class Main {
    public static boolean mayRetire(Instant now, Instant announcedAt,
                                    long noticeDays, double adoption,
                                    double requiredAdoption) {
        // TODO: validate policy inputs and enforce every retirement gate
        return false;
    }
}
$code$), true),
    ('principal-cost-optimizer', 'Compare Cost per Successful Request', 'Compare alternatives using successful useful work rather than raw request volume, and reject invalid telemetry.', 'Principal', 'Principal', 'Architecture', jsonb_build_object('Main.java', $code$public class Main {
    public static double costPerSuccess(double cost, long successfulRequests) {
        // TODO: validate inputs and avoid misleading zero-denominator results
        return 0;
    }
}
$code$), true),
    ('principal-incident-governance', 'Set Incident Escalation Gates', 'Escalate based on customer impact, duration, and uncertainty while keeping the response proportional and auditable.', 'Principal', 'Principal', 'Technical Leadership', jsonb_build_object('Main.java', $code$public class Main {
    public static boolean escalate(int affectedUsers, long durationMinutes,
                                   boolean dataIntegrityAtRisk, int userThreshold,
                                   long durationThreshold) {
        // TODO: escalate promptly for material impact or integrity risk
        return false;
    }
}
$code$), true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO challenge_skill (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
    ('junior-string-analyzer', 'java-fundamentals'),
    ('junior-grade-book', 'collections'),
    ('junior-library-inventory', 'object-oriented-design'),
    ('junior-date-range', 'java-syntax'),
    ('junior-csv-summary', 'exceptions'),
    ('mid-paginated-results', 'api-design'),
    ('mid-cache-expiration', 'resilience'),
    ('mid-resilient-batch', 'testing'),
    ('mid-circuit-breaker', 'resilience'),
    ('mid-event-deduplicator', 'distributed-systems'),
    ('senior-bounded-executor', 'concurrency'),
    ('senior-snapshot-consistency', 'distributed-systems'),
    ('senior-transaction-retry', 'sql-persistence'),
    ('senior-cache-stampede', 'concurrency'),
    ('senior-audit-pipeline', 'observability'),
    ('lead-tenant-quota', 'architecture'),
    ('lead-schema-rollout', 'sql-persistence'),
    ('lead-service-migration', 'technical-leadership'),
    ('lead-slo-budget', 'observability'),
    ('lead-queue-backpressure', 'resilience'),
    ('principal-data-residency', 'architecture'),
    ('principal-consistency-model', 'distributed-systems'),
    ('principal-deprecation-plan', 'api-design'),
    ('principal-cost-optimizer', 'architecture'),
    ('principal-incident-governance', 'technical-leadership')
) AS wanted(challenge_slug, skill_slug)
JOIN challenge c ON c.slug = wanted.challenge_slug
JOIN skill s ON s.slug = wanted.skill_slug
ON CONFLICT DO NOTHING;

INSERT INTO challenge_requirement (challenge_id, description, sort_order)
SELECT c.id, requirement.description, requirement.sort_order
FROM (VALUES
    ('junior-string-analyzer', 'Treat null and blank input consistently and document that behavior.', 1),
    ('junior-string-analyzer', 'Count whitespace-delimited words without counting repeated spaces as empty words.', 2),
    ('junior-string-analyzer', 'Handle punctuation and Unicode text without crashing.', 3),
    ('junior-grade-book', 'Handle null and empty score lists without division by zero.', 1),
    ('junior-grade-book', 'Reject or safely handle null and out-of-range scores.', 2),
    ('junior-grade-book', 'Calculate the average without integer truncation.', 3),
    ('junior-library-inventory', 'Reject negative capacity and keep available copies within zero and capacity.', 1),
    ('junior-library-inventory', 'A checkout succeeds only when a copy is available.', 2),
    ('junior-library-inventory', 'A return cannot increase inventory above its original capacity.', 3),
    ('junior-date-range', 'Reject missing endpoints.', 1),
    ('junior-date-range', 'Accept a same-day range and a range whose end follows its start.', 2),
    ('junior-date-range', 'Reject an end date before the start date.', 3),
    ('junior-csv-summary', 'Trim each field and preserve field order.', 1),
    ('junior-csv-summary', 'Define behavior for null, blank, and empty fields.', 2),
    ('junior-csv-summary', 'Document that this exercise handles simple CSV without quoted commas.', 3),
    ('mid-paginated-results', 'Require a non-negative page and a size from one through the configured maximum.', 1),
    ('mid-paginated-results', 'Calculate the offset using arithmetic that cannot silently overflow.', 2),
    ('mid-paginated-results', 'Reject null requests with a clear contract failure.', 3),
    ('mid-cache-expiration', 'Reject invalid timestamps, negative TTL values, and null inputs.', 1),
    ('mid-cache-expiration', 'Treat the exact expiry instant consistently as expired.', 2),
    ('mid-cache-expiration', 'Avoid overflow when calculating expiration for extreme durations.', 3),
    ('mid-resilient-batch', 'Classify every input item exactly once.', 1),
    ('mid-resilient-batch', 'Preserve input order in success and failure results.', 2),
    ('mid-resilient-batch', 'Do not discard successful outcomes when another item fails.', 3),
    ('mid-circuit-breaker', 'Reject calls while the breaker is open.', 1),
    ('mid-circuit-breaker', 'Limit half-open probes to the configured positive bound.', 2),
    ('mid-circuit-breaker', 'Handle null state and invalid counters explicitly.', 3),
    ('mid-event-deduplicator', 'A previously seen event identifier is not processed twice.', 1),
    ('mid-event-deduplicator', 'Reject null or blank identifiers.', 2),
    ('mid-event-deduplicator', 'Explain how identifier retention is bounded in a production implementation.', 3),
    ('senior-bounded-executor', 'Never allow active work to exceed a positive limit.', 1),
    ('senior-bounded-executor', 'Reject invalid limits and avoid incrementing state for rejected work.', 2),
    ('senior-bounded-executor', 'Provide a matching release operation that cannot underflow.', 3),
    ('senior-snapshot-consistency', 'Reject null values and invalid version numbers.', 1),
    ('senior-snapshot-consistency', 'Accept values only when their snapshot versions match.', 2),
    ('senior-snapshot-consistency', 'Do not claim that equal versions prove freshness without a source contract.', 3),
    ('senior-transaction-retry', 'Retry only classified transient failures.', 1),
    ('senior-transaction-retry', 'Stop at the attempt limit or when the remaining deadline is exhausted.', 2),
    ('senior-transaction-retry', 'Reject invalid attempt counts and null or negative durations.', 3),
    ('senior-cache-stampede', 'Concurrent callers for one key share a single in-flight future.', 1),
    ('senior-cache-stampede', 'Different keys can refresh independently.', 2),
    ('senior-cache-stampede', 'Remove completed or failed refreshes so future attempts can proceed.', 3),
    ('senior-audit-pipeline', 'Accept only positive sequence values that immediately follow the prior value.', 1),
    ('senior-audit-pipeline', 'Detect duplicates, gaps, and invalid prior sequence values.', 2),
    ('senior-audit-pipeline', 'Do not imply that per-aggregate order establishes global event order.', 3),
    ('lead-tenant-quota', 'Reject missing tenant identity and invalid counts or limits.', 1),
    ('lead-tenant-quota', 'Enforce both per-tenant and global capacity without cross-tenant borrowing.', 2),
    ('lead-tenant-quota', 'Document how quota configuration changes take effect safely.', 3),
    ('lead-schema-rollout', 'Do not remove old schema while old application writers remain.', 1),
    ('lead-schema-rollout', 'Allow contract phase only after migration and read-switch evidence exists.', 2),
    ('lead-schema-rollout', 'Define safe behavior for null or unknown rollout phase.', 3),
    ('lead-service-migration', 'Require verified target data and a healthy target before cutover.', 1),
    ('lead-service-migration', 'Keep rollback readiness as an explicit cutover gate.', 2),
    ('lead-service-migration', 'Make the decision fail closed when evidence is missing.', 3),
    ('lead-slo-budget', 'Accept only finite availability targets and observed ratios in the range zero to one.', 1),
    ('lead-slo-budget', 'Calculate budget remaining after observed failures without returning negative remaining budget.', 2),
    ('lead-slo-budget', 'Reject invalid values rather than reporting a success-shaped number.', 3),
    ('lead-queue-backpressure', 'Reject admission when queue depth reaches its configured maximum.', 1),
    ('lead-queue-backpressure', 'Reject admission when oldest-message age reaches its configured maximum.', 2),
    ('lead-queue-backpressure', 'Handle negative measurements and invalid limits explicitly.', 3),
    ('principal-data-residency', 'Allow a destination only when it is explicitly present in a known policy.', 1),
    ('principal-data-residency', 'Fail closed for null, blank, or unknown regions and policy.', 2),
    ('principal-data-residency', 'Treat residency as a data-flow property, not only a primary database setting.', 3),
    ('principal-consistency-model', 'Use strong consistency when the operation protects a critical invariant.', 1),
    ('principal-consistency-model', 'Choose eventual consistency only when stale reads are explicitly acceptable.', 2),
    ('principal-consistency-model', 'Fail toward stronger guarantees when inputs are missing or contradictory.', 3),
    ('principal-deprecation-plan', 'Validate adoption ratios, notice duration, and required threshold.', 1),
    ('principal-deprecation-plan', 'Require the notice period and adoption threshold before retirement.', 2),
    ('principal-deprecation-plan', 'Handle future announcement dates and invalid timestamps safely.', 3),
    ('principal-cost-optimizer', 'Reject non-finite or negative costs and negative request counts.', 1),
    ('principal-cost-optimizer', 'Do not present a finite cost-per-success value when no successful requests exist.', 2),
    ('principal-cost-optimizer', 'Use successful useful work as the denominator, not total attempts.', 3),
    ('principal-incident-governance', 'Escalate immediately when data integrity is at risk.', 1),
    ('principal-incident-governance', 'Escalate when either the affected-user or duration threshold is reached.', 2),
    ('principal-incident-governance', 'Reject invalid thresholds and measurements explicitly.', 3)
) AS requirement(challenge_slug, description, sort_order)
JOIN challenge c ON c.slug = requirement.challenge_slug
WHERE NOT EXISTS (
    SELECT 1
    FROM challenge_requirement existing
    WHERE existing.challenge_id = c.id
      AND existing.sort_order = requirement.sort_order
);
