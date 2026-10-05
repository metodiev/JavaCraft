-- V25 — Microservices engineering patterns.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('api-gateway-patterns', 'API Gateway Patterns', 'Place cross-cutting concerns at the edge while keeping routing stateless and the gateway observable.', 'Senior', 38, true, 1),
    ('service-discovery-in-practice', 'Service Discovery in Practice', 'Compare client-side and server-side discovery and plan for registry health and stale caches.', 'Senior', 36, true, 1),
    ('centralised-configuration', 'Centralised Configuration', 'Externalize configuration safely with clear refresh scope, override precedence, and startup failure modes.', 'Senior', 34, true, 1),
    ('circuit-breaker-patterns', 'Circuit Breaker Patterns', 'Tune breaker thresholds, half-open probing, and fallbacks without turning health checks into outages.', 'Senior', 36, true, 1),
    ('bulkheads-and-pool-isolation', 'Bulkheads and Pool Isolation', 'Contain dependency failures with isolated pools and know when semaphores beat thread pools.', 'Mid', 30, true, 1),
    ('retry-storm-prevention', 'Retry Storm Prevention', 'Bound and jitter retries so clients help dependencies recover instead of amplifying outages.', 'Mid', 32, true, 1),
    ('distributed-transactions-and-sagas', 'Distributed Transactions and Sagas', 'Understand the limits of two-phase commit and design sagas with testable compensations.', 'Mid', 34, true, 1),
    ('transactional-outbox-pattern', 'Transactional Outbox Pattern', 'Publish events atomically with database writes and keep consumers safe under duplication.', 'Senior', 38, true, 1),
    ('idempotency-in-distributed-systems', 'Idempotency in Distributed Systems', 'Design operations whose repeated delivery produces one effect using keys and deduplication stores.', 'Senior', 34, true, 1),
    ('distributed-tracing-in-java', 'Distributed Tracing in Java', 'Propagate W3C trace context through Java services and use baggage without leaking data.', 'Senior', 36, true, 1),
    ('correlation-ids-and-request-context', 'Correlation IDs and Request Context', 'Give each request an identity, carry it across threads, and log so incidents are reconstructable.', 'Mid', 28, true, 1),
    ('synchronous-vs-asynchronous-service-calls', 'Synchronous versus Asynchronous Service Calls', 'Decide when temporal coupling is acceptable and when queues or events serve the workflow better.', 'Senior', 34, true, 1),
    ('service-contract-evolution', 'Service Contract Evolution', 'Evolve service interfaces with consumer-driven contracts, versioning policy, and honest sunsets.', 'Mid', 30, true, 1),
    ('multi-tenancy-strategies', 'Multi-Tenancy Strategies', 'Choose shared schema, schema per tenant, or database per tenant and control noisy neighbours.', 'Lead', 40, true, 1),
    ('strangler-fig-migration', 'Strangler Fig Migration', 'Replace a monolith incrementally with routing seams, data synchronisation, and real retirement.', 'Lead', 40, true, 1),
    ('microservices-anti-patterns', 'Microservices Anti-Patterns', 'Recognize distributed monoliths, chatty interfaces, and shared databases before they calcify.', 'Lead', 42, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('api-gateway-patterns', 1, 'What belongs at the edge', $body$An edge gateway terminates TLS, authenticates callers, and routes requests to internal services. Those cross-cutting jobs are worth centralising because every service would otherwise reimplement them with subtle differences. The gateway can also enforce quotas, apply compression, and normalise headers. It should not own domain rules: pricing, entitlement, and workflow decisions belong to the service that owns the data. Keep the gateway stateless so instances scale horizontally, and keep route configuration declarative and versioned. Rule of thumb: if a change at the edge requires knowledge of a business entity, it probably belongs behind the gateway.$body$, $code$spring:
  cloud:
    gateway:
      routes:
        - id: orders
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1
            - TokenRelay=$code$),
    ('api-gateway-patterns', 2, 'Aggregation is usually an anti-pattern', $body$It is tempting to let the gateway call five services and merge their responses into one convenient payload. That turns a routing component into an orchestrator that must handle partial failures, timeouts, caching, and schema evolution for every backend. Failures become ambiguous, and one slow dependency stalls the whole aggregation. If a client genuinely needs a composite view, build a dedicated backend-for-frontend service that owns the composition, the fallbacks, and the latency budget. Let the gateway forward and enforce, not compose. Rule of thumb: a gateway route should map to one upstream service; if it maps to a fan-out, move that logic into an owned service.$body$, $code$// Composition lives in a service with its own SLO, not in the gateway
class OrderSummaryBff {
    OrderSummary load(long id) {
        Order order = orderClient.get(id);
        Customer customer = customerClient.get(order.customerId());
        return new OrderSummary(order, customer);
    }
}$code$),
    ('api-gateway-patterns', 3, 'When the gateway becomes the bottleneck', $body$Every request crossing the gateway adds a network hop, so the edge must be sized for peak traffic and watched for saturation before internal services degrade. Symptoms include rising p99 latency at the edge while backends look healthy, connection pool exhaustion, and thread starvation in blocking filters. Shared route definitions also create organisational coupling: one broken route change can affect every team. Mitigate with horizontal scaling, non-blocking routing, per-route rate limits, and canary deploys of configuration. Rule of thumb: treat the gateway as a production service with its own SLO, load tests, and on-call rotation rather than transparent plumbing.$body$, $code$spring:
  cloud:
    gateway:
      httpclient:
        connect-timeout: 300
        response-timeout: 2s$code$),
    ('service-discovery-in-practice', 1, 'Client-side versus server-side discovery', $body$With client-side discovery the caller asks a registry for healthy instances and load-balances across them itself; Spring Cloud LoadBalancer with Eureka or Consul is the classic Java stack. With server-side discovery the caller uses a stable endpoint and an infrastructure component such as a Kubernetes Service or load balancer does the choosing. Client-side gives finer control over balancing and retries but pushes discovery logic into every client and language. Server-side keeps clients simple but hides instance health from the application. Rule of thumb: on Kubernetes, prefer server-side discovery through Services; reach for a client registry mainly when balancing policy or metadata-based routing genuinely matters.$body$, $code$WebClient client = WebClient.builder()
    .baseUrl("lb://order-service")
    .build();

Order order = client.get()
    .uri("/orders/{id}", id)
    .retrieve()
    .bodyToMono(Order.class)
    .block(Duration.ofSeconds(2));$code$),
    ('service-discovery-in-practice', 2, 'Registry health versus DNS resolution', $body$A service registry records registration, heartbeat, and deregistration, so it reflects liveness only as accurately as heartbeats allow. A crashed instance can remain listed until its lease expires, and clients that cached the instance list keep sending traffic to it in the meantime. DNS resolves names to addresses but usually lacks per-instance health and has its own TTL and JVM caching layers. Neither eliminates the need for timeouts, retries, and breakers at the call site. Rule of thumb: treat discovery as a hint that reduces failed attempts; correctness still depends on defensive client behaviour.$body$, $code$eureka:
  client:
    service-url:
      defaultZone: https://registry.example.com/eureka
    registry-fetch-interval-seconds: 10
  instance:
    lease-renewal-interval-in-seconds: 10
    lease-expiration-duration-in-seconds: 30$code$),
    ('service-discovery-in-practice', 3, 'Stale caches and refresh stamps', $body$Discovery clients cache instance lists to avoid querying the registry on every call. That cache is a trade-off: longer refresh intervals reduce registry load but extend the window in which callers target dead instances; shorter intervals increase load and can cause registry stampedes after a cold start. When the registry itself is unavailable, clients should keep serving from their last known good list rather than failing all traffic. Plan for the thundering herd when a large fleet refreshes simultaneously. Rule of thumb: size the refresh interval against your deployment rate, add jitter, and alert when registry refresh latency or stale-cache age grows.$body$, $code$spring:
  cloud:
    loadbalancer:
      cache:
        enabled: true
        ttl: 10s
        capacity: 256$code$),
    ('centralised-configuration', 1, 'Externalise configuration and keep it reviewable', $body$Centralised configuration stores environment-specific values outside the artefact so one build can run in every environment. Spring Cloud Config serves properties from a Git repository; alternatives include Consul, etcd, Kubernetes ConfigMaps, and cloud parameter stores. Whichever you choose, treat configuration as versioned, reviewable, and attributable: a Git-backed config repository gives you history, pull requests, and rollback for free. Keep secrets in a dedicated secret store rather than the same repository as ordinary settings. Rule of thumb: application code should fail fast at startup when a required setting is missing, rather than silently falling back to a default that was only meant for local development.$body$, $code$spring:
  application:
    name: order-service
  config:
    import: configserver:https://config.example.com
  cloud:
    config:
      fail-fast: true
      retry:
        max-attempts: 6$code$),
    ('centralised-configuration', 2, 'Refresh semantics and bean scope', $body$Refreshing configuration changes beans resolved through a refresh scope; it does not retroactively rewrite values already copied into long-lived objects. In Spring Cloud, the refresh scope recreates the bean on refresh, so state kept in that bean is lost, and configuration properties beans rebind. Refresh is typically triggered per instance through an actuator endpoint or broadcast through a message bus. Because a fleet refreshes at slightly different times, code must tolerate two configurations running simultaneously. Rule of thumb: never require a configuration change and a code change to be released together, and make every setting safe to change while traffic is flowing.$body$, $code$@Component
@RefreshScope
class PricingSettings {
    @Value("${pricing.vat.rate}")
    private BigDecimal vatRate;

    BigDecimal gross(BigDecimal net) {
        return net.multiply(BigDecimal.ONE.add(vatRate));
    }
}$code$),
    ('centralised-configuration', 3, 'Override precedence and startup failure modes', $body$Layered overrides let a service ship sane defaults while environments tune behaviour. Order matters: command-line arguments and environment variables usually outrank remote configuration, which outranks packaged defaults. Document the precedence, because debugging a value overridden three levels deep is expensive. Availability matters too: decide whether the service starts when the config server is unreachable, and prefer a fail-fast startup with a small local cache over running with silently wrong settings. Rule of thumb: keep the number of layers small, name keys consistently, and log the resolved value of every operationally significant setting at startup without logging secrets.$body$, $code$# Packaged defaults; environments override at deploy time
pricing:
  vat:
    rate: ${PRICING_VAT_RATE:0.20}
  currency: ${PRICING_CURRENCY:EUR}$code$),
    ('circuit-breaker-patterns', 1, 'States, transitions, and caller behaviour', $body$A circuit breaker wraps a call and tracks outcomes. In the closed state calls pass through while failures are counted. When the failure rate crosses a threshold over a minimum number of calls, the breaker opens and calls fail immediately with a fallback instead of waiting on a sick dependency. After a wait duration it moves to half-open and admits a limited number of probe calls: successes close it again, a failure reopens it. That fast failure is the point: it protects callers from slow timeouts and gives the dependency room to recover. Rule of thumb: always pair a breaker with a bounded timeout and a meaningful fallback.$body$, $code$CircuitBreaker breaker = CircuitBreaker.of("inventory",
    CircuitBreakerConfig.custom()
        .slidingWindowSize(20)
        .minimumNumberOfCalls(10)
        .failureRateThreshold(50.0f)
        .waitDurationInOpenState(Duration.ofSeconds(30))
        .permittedNumberOfCallsInHalfOpenState(3)
        .build());

Supplier<Stock> guarded = CircuitBreaker.decorateSupplier(breaker, inventoryClient::stock);
Try<Stock> result = Try.ofSupplier(guarded)
    .recover(throwable -> Stock.unknown());$code$),
    ('circuit-breaker-patterns', 2, 'Thresholds, windows, and probing', $body$Configuration decides whether a breaker helps or thrashes. A count-based window reacts quickly to low traffic; a time-based window smooths bursts but needs enough duration to accumulate evidence. Slow-call thresholds catch dependencies that respond but too slowly, which pure failure counting misses. Set the minimum number of calls so a handful of failures cannot trip the breaker, and keep the half-open permit count small so probing does not become a traffic spike. Rule of thumb: tune thresholds from observed latency and error budgets, not from defaults, and remember that opening a breaker is itself a user-visible degradation.$body$, $code$CircuitBreakerConfig config = CircuitBreakerConfig.custom()
    .slidingWindowType(SlidingWindowType.TIME_BASED)
    .slidingWindowSize(60)
    .minimumNumberOfCalls(20)
    .slowCallDurationThreshold(Duration.ofMillis(800))
    .slowCallRateThreshold(60.0f)
    .build();$code$),
    ('circuit-breaker-patterns', 3, 'Do not couple breakers to health checks', $body$Exposing breaker state as a liveness or readiness signal looks appealing but is dangerous. If a dependency degrades, the readiness probe fails, the orchestrator removes otherwise healthy instances, capacity shrinks, and the remaining instances take more load: a self-inflicted outage. Health endpoints should describe the process itself, while dependency state belongs in metrics and alerts. Breakers are per-dependency and per-caller; readiness is per-instance. Rule of thumb: fail readiness only when the instance cannot serve any traffic at all, and surface degraded dependencies through dashboards, logs, and explicit fallback responses instead.$body$, $code$management:
  endpoint:
    health:
      group:
        readiness:
          include: db, diskSpace$code$),
    ('bulkheads-and-pool-isolation', 1, 'Contain the blast radius', $body$A bulkhead limits how many concurrent calls one dependency can consume, so a slow or hanging dependency cannot exhaust the resources shared with everything else. Without it, one unhealthy integration can fill the entire thread pool or connection pool and take down unrelated endpoints. Isolation is applied per dependency, per tenant, or per client class, depending on what you must protect. The trade-off is strict: capacity reserved for one dependency is unavailable to others, so total utilisation drops slightly in exchange for predictable failure. Rule of thumb: isolate any dependency that is slower, less reliable, or managed by a different team than your own.$body$, $code$BulkheadConfig config = BulkheadConfig.custom()
    .maxConcurrentCalls(25)
    .maxWaitDuration(Duration.ofMillis(50))
    .build();

Bulkhead bulkhead = Bulkhead.of("payment", config);
Supplier<Receipt> guarded = Bulkhead.decorateSupplier(bulkhead, paymentClient::charge);$code$),
    ('bulkheads-and-pool-isolation', 2, 'Thread pool versus semaphore bulkheads', $body$A semaphore bulkhead limits concurrent executions on the calling thread and adds almost no overhead, but blocking calls still occupy that thread. A thread pool bulkhead runs work on a dedicated pool, so the caller can time out independently and slow dependencies cannot pin request threads; the cost is extra context switching and queueing. Choose semaphores for fast or non-blocking calls and thread pools when you must cap queueing and preserve response times for other traffic. Rule of thumb: if a dependency can block for seconds, isolate it with its own threads and a bounded queue instead of relying on a counter.$body$, $code$ThreadPoolBulkheadConfig pool = ThreadPoolBulkheadConfig.custom()
    .maxThreadPoolSize(8)
    .coreThreadPoolSize(4)
    .queueCapacity(32)
    .keepAliveDuration(Duration.ofMillis(20))
    .build();

ThreadPoolBulkhead bulkhead = ThreadPoolBulkhead.of("report-export", pool);
CompletionStage<Report> future = bulkhead.executeSupplier(reportClient::export);$code$),
    ('bulkheads-and-pool-isolation', 3, 'Size pools from dependency capacity', $body$A pool size sets the maximum load you will send to a dependency, so derive it from the dependency capacity divided by the number of callers, not from the number of threads you have. Add a short wait duration so callers fail fast instead of piling up, and use bounded queues everywhere. Then watch the signals that matter: rejections, queue depth, wait time, and saturation of the pool. Persistent rejections mean either undersized isolation or an over-burdened dependency, and both are actionable. Rule of thumb: a bulkhead that never rejects under normal peak load is probably too large to contain anything.$body$, $code$resilience4j:
  bulkhead:
    instances:
      payment:
        maxConcurrentCalls: 25
        maxWaitDuration: 50ms$code$),
    ('retry-storm-prevention', 1, 'Retries multiply load', $body$A retry is an extra request, and every layer that retries multiplies the others. Three layers with three attempts each turn one failing call into twenty-seven requests, so a struggling dependency receives a surge exactly when it can least handle it. Worst of all, retries are usually synchronised: clients that timed out together retry together. Before adding a retry, prove the failure is transient and that the operation is safe to repeat. Rule of thumb: retry in one place, close to the caller who knows the operation semantics, and never retry on the server side of a synchronous call chain.$body$, $code$RetryConfig config = RetryConfig.custom()
    .maxAttempts(3)
    .retryExceptions(ConnectException.class, TimeoutException.class)
    .ignoreExceptions(CardDeclinedException.class)
    .build();$code$),
    ('retry-storm-prevention', 2, 'Jitter and exponential backoff', $body$Immediate retries keep pressure on a saturated dependency. Exponential backoff with random jitter spreads attempts across time so the fleet does not stampede. Jitter matters more than the exact formula: full jitter, where the delay is chosen randomly between zero and the computed backoff, is simple and effective. Cap the maximum delay and the total number of attempts, and abandon retries when the caller deadline is already exhausted. Rule of thumb: if the expected recovery time exceeds your caller timeout, retry asynchronously or fail fast with a clear error instead of holding connections.$body$, $code$RetryConfig config = RetryConfig.custom()
    .maxAttempts(5)
    .intervalFunction(IntervalFunction.ofExponentialRandomBackoff(
        200, 2.0, 0.5, 5000))
    .build();$code$),
    ('retry-storm-prevention', 3, 'Budgets and coordination policy', $body$A retry budget caps retries as a fraction of successful requests, so a small number of failures cannot generate unbounded extra traffic. This is the mechanism behind mesh retry budgets and it pairs well with per-client rate limits. It also exposes an operational truth: retry behaviour is a policy decision shared across teams, not a private library default. Track retry rate, success-after-retry, and the latency retries add. If success-after-retry is low, retries are only amplifying failure. Rule of thumb: allow retries only while the budget holds, and alert when retry traffic exceeds a few percent of total requests.$body$, $code$RateLimiterConfig budget = RateLimiterConfig.custom()
    .limitForPeriod(20)
    .limitRefreshPeriod(Duration.ofSeconds(1))
    .timeoutDuration(Duration.ZERO)
    .build();

RateLimiter limiter = RateLimiter.of("retry-budget", budget);
Supplier<Stock> guarded = RateLimiter.decorateSupplier(limiter, inventoryClient::stock);$code$),
    ('distributed-transactions-and-sagas', 1, 'Why two-phase commit does not scale', $body$Two-phase commit coordinates participants through a prepare and commit phase with a transaction manager. It gives atomicity but holds locks from prepare until commit, so latency is bounded by the slowest participant, and one unavailable coordinator or participant can leave resources locked. Many modern stores and brokers do not support the XA protocol at all, and cross-service locks conflict with independent deployment and availability goals. That is why distributed transactions across microservices are usually avoided. Rule of thumb: keep a single ACID transaction inside one service and its database, then coordinate across services with explicit state and compensation.$body$, $code$// Each step commits locally; no distributed lock is held across services.
@Transactional
void reserveStock(long orderId, int quantity) {
    stockRepository.decrement(quantity);
    sagaRepository.markStep(orderId, "STOCK_RESERVED");
}$code$),
    ('distributed-transactions-and-sagas', 2, 'Choreography versus orchestration', $body$In a choreographed saga each service reacts to events and decides its next step, which keeps coupling low but makes the overall flow hard to see and to debug. In an orchestrated saga a coordinator invokes participants in order and tracks progress, giving visibility, explicit timeouts, and simpler compensation, at the cost of a central component. Choose orchestration when the process has many steps, strict SLAs, or regulatory visibility; choose choreography for short, stable flows between a few services. Rule of thumb: draw the end-to-end flow before choosing, and remember that either style still needs idempotent steps and durable state.$body$, $code$class OrderSaga {
    void execute(OrderContext context) {
        try {
            reserveStock.apply(context);
            chargePayment.apply(context);
        } catch (PaymentFailed failure) {
            reserveStock.compensate(context);
            throw failure;
        }
    }
}$code$),
    ('distributed-transactions-and-sagas', 3, 'Designing compensating actions', $body$A compensating action undoes the business effect of a completed step; it is not a rollback, because the original transaction is gone. Compensations must be idempotent, ordered in reverse where the effect requires it, and able to fail without blocking the rest of the flow. Steps that cannot be undone, such as sending an email or shipping a parcel, need a different remedy: a corrective business action or a manual queue. Persist saga state so you can resume after a crash, and emit clear events for observability. Rule of thumb: design the compensation for every step before writing the forward path.$body$, $code$@Transactional
public void compensate(OrderContext context) {
    if (context.stockReserved()) {
        stockRepository.increment(context.items());
    }
    sagaRepository.markCompensated(context.orderId(), "STOCK_RESERVED");
}$code$),
    ('transactional-outbox-pattern', 1, 'One commit, two writes', $body$Publishing an event after committing to the database creates a gap: the process can crash between the two actions, losing the event, or publish before commit and announce something that never happened. The outbox pattern closes that gap by writing the event into an outbox table in the same local transaction as the business change. One commit makes both facts true or neither. The event is then published from the outbox by a separate process, which trades immediate publication for guaranteed capture. Rule of thumb: never do a database write and a broker publish in the same code path without an outbox between them.$body$, $code$BEGIN;
INSERT INTO order_header (id, customer_id, total, status)
VALUES (:id, :customerId, :total, 'PLACED');
INSERT INTO outbox (id, aggregate_id, event_type, payload, created_at)
VALUES (gen_random_uuid(), :id, 'OrderPlaced', :payload, now());
COMMIT;$code$),
    ('transactional-outbox-pattern', 2, 'Relay procedures and trade-offs', $body$A relay reads unpublished rows and sends them to the broker, then marks them published. Polling is simple and portable but adds query load and latency; change data capture streams the transaction log with lower latency and no extra queries, at the cost of more infrastructure. Either way the relay is at-least-once: it can send duplicates when it crashes after publishing but before marking. Keep the outbox small by deleting or archiving published rows, and order rows per aggregate when consumers depend on sequence. Rule of thumb: treat the relay as untrusted infrastructure and make consumers tolerant of repeated delivery.$body$, $code$SELECT id, aggregate_id, event_type, payload
FROM outbox
WHERE published_at IS NULL
ORDER BY created_at
LIMIT 100
FOR UPDATE SKIP LOCKED;$code$),
    ('transactional-outbox-pattern', 3, 'Deduplication and ordering on consumers', $body$Because delivery is at least once, consumers must deduplicate using a stable event identifier. Store processed identifiers in the same transaction as the consumer state change, so the mark and the work commit together. Keep a retention window long enough to cover realistic retry and replay horizons, then let old identifiers expire. Global ordering across partitions is not available, so design handlers that tolerate out-of-order arrival, for example by comparing versions or by ignoring stale updates. Rule of thumb: assume every event can arrive twice, out of order, and after the next one, and make the handler correct under all three.$body$, $code$BEGIN;
INSERT INTO processed_event (consumer, event_id, processed_at)
VALUES ('billing', :eventId, now())
ON CONFLICT (consumer, event_id) DO NOTHING;
UPDATE invoice SET status = 'PAID' WHERE order_id = :orderId;
COMMIT;$code$),
    ('idempotency-in-distributed-systems', 1, 'Exactly once is an illusion', $body$Networks cannot distinguish a lost response from a lost request, so a client that times out and retries may cause duplicate work even though both sides behaved correctly. Exactly-once delivery is not achievable end to end; exactly-once effects are, and they come from making the receiving operation idempotent. Distributed systems build this from at-least-once delivery plus deduplication, or from operations that are naturally safe to repeat, such as setting a value to a specific state. Rule of thumb: design the operation so that applying it twice equals applying it once, then you no longer depend on delivery guarantees you do not control.$body$, $code$// Repeating this call sets the same state, so a retry is harmless.
public void applyLimit(long accountId, BigDecimal limit) {
    accounts.updateLimit(accountId, limit);
}

// A retry after a timeout produces the same stored limit,
// so the client can safely repeat the request.$code$),
    ('idempotency-in-distributed-systems', 2, 'Keys, stores, and result replay', $body$The common mechanism is a client-supplied idempotency key plus a deduplication store. The first request records the key with an in-progress marker, performs the work, and stores the outcome; a retry with the same key returns the stored response instead of repeating the effect. The key must be scoped, usually per client and per operation, and it must be unique across retries of the same logical request. Store enough of the original response to answer retries, including the status code. Rule of thumb: return the same body for a repeated key so callers cannot tell whether they received the original or a replay.$body$, $code$CREATE TABLE idempotency_record (
    client_id    TEXT NOT NULL,
    key          TEXT NOT NULL,
    request_hash TEXT NOT NULL,
    status_code  INT,
    response     JSONB,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (client_id, key)
);$code$),
    ('idempotency-in-distributed-systems', 3, 'Concurrency, scope, and expiry', $body$Two concurrent requests can carry the same key. Rely on a unique constraint rather than a read-then-write check, and let the loser either wait for the winner or return a conflict while work is in progress. Decide how long keys live: too long and storage grows, too short and a slow retry creates a duplicate. Also match the request to the key by storing a fingerprint of the payload, so a key reused with different content is rejected rather than silently returning the wrong result. Rule of thumb: deduplicate inside the same transaction as the effect, and treat key reuse with different payloads as a client error.$body$, $code$-- Winner inserts and proceeds; loser reads the stored response.
INSERT INTO idempotency_record (client_id, key, request_hash)
VALUES (:clientId, :key, :hash)
ON CONFLICT (client_id, key) DO NOTHING
RETURNING status_code;

-- A zero-row insert means the key already exists:
-- compare request_hash, then return the stored status and body.$code$),
    ('distributed-tracing-in-java', 1, 'Context propagation with traceparent', $body$A trace is a tree of spans sharing a trace identifier; each span records one unit of work and points at its parent. Services exchange that context in headers, so the W3C Trace Context recommendation defines traceparent, which carries version, trace id, parent span id, and trace flags, plus tracestate for vendor data. Propagating context is what turns isolated service logs into one picture. Failures to propagate break the tree into unrelated fragments, which is the most common reason a trace looks incomplete. Rule of thumb: verify propagation on every hop you own, including queues, scheduled jobs, and outbound HTTP clients.$body$, $code$GET /orders/42 HTTP/1.1
Host: order-service
traceparent: 00-8b2f1c9d4e5a4b3c8d7e6f5a4b3c2d1e-4f3e2d1c0b9a8776-01
tracestate: acme=tenant-42

HTTP/1.1 200 OK
traceparent: 00-8b2f1c9d4e5a4b3c8d7e6f5a4b3c2d1e-91a2b3c4d5e6f708-01$code$),
    ('distributed-tracing-in-java', 2, 'Instrumenting Spring services', $body$Modern Spring Boot uses Micrometer Tracing with a bridge to OpenTelemetry or Brave; adding the bridge and an exporter wires HTTP servers, clients, and common integrations automatically. Messaging, JDBC, and gRPC need their instrumentation modules present, and manual spans are worth adding only around meaningful operations such as a batch job. Sampling decides cost: head-based sampling is cheap but may drop interesting traces, so many teams sample a small percentage and keep errors through tail sampling in the collector. Rule of thumb: set the sampling probability explicitly per environment, export over an open protocol, and check that trace ids appear in logs.$body$, $code$management:
  tracing:
    sampling:
      probability: 0.1
  otlp:
    tracing:
      endpoint: http://collector:4318/v1/traces$code$),
    ('distributed-tracing-in-java', 3, 'Baggage caution and sampling', $body$Baggage carries arbitrary key-value pairs across service boundaries alongside trace context. It is convenient for experimentation identifiers and tenant hints, but it travels on every hop, is easy to leak into third-party calls, and has no defined size or privacy semantics. Because baggage is user data, never place secrets, tokens, or personal information in it. Prefer explicit request headers or claims-based identity for anything a service actually needs, and use baggage only for diagnostics that can tolerate loss. Rule of thumb: if removing a baggage entry would break a business decision, promote it to a real contract field.$body$, $code$management:
  tracing:
    baggage:
      enabled: true
      remote-fields:
        - tenant-id
        - experiment-id$code$),
    ('correlation-ids-and-request-context', 1, 'Every request gets an identity', $body$A correlation identifier is a value that ties together all log lines and downstream calls produced by one logical request. Accept an inbound identifier when a caller provides one so traces span ownership boundaries, and generate a fresh one when it is missing or malformed. Record it on every outbound call, including asynchronous messages and scheduled follow-up work, otherwise the trail ends at the first hop. Correlation identifiers are not authentication: never trust one for authorization decisions. Rule of thumb: return the identifier in the response headers so users can quote it in support tickets.$body$, $code$String correlationId = request.getHeader("X-Correlation-Id");
if (correlationId == null || correlationId.isBlank()) {
    correlationId = UUID.randomUUID().toString();
}
response.setHeader("X-Correlation-Id", correlationId);$code$),
    ('correlation-ids-and-request-context', 2, 'MDC across threads and async work', $body$In Java the natural home for request context is the logging MDC, which is thread-local. That works until work moves to another thread: thread pools reuse threads, so context leaks between requests unless you clear and set it, and tasks submitted without a wrapper lose it entirely. Spring provides a task decorator to copy context into executors, and reactive stacks need context propagation through the reactive context instead. Whatever the mechanism, clear state in a finally block. Rule of thumb: put identifiers in the MDC at the boundary, propagate explicitly across every async hop, and remove them before the thread returns to the pool.$body$, $code$protected void doFilterInternal(request, response, chain) throws IOException, ServletException {
    String id = correlationId(request);
    try (MDC.MDCCloseable ignored = MDC.putCloseable("correlationId", id)) {
        response.setHeader("X-Correlation-Id", id);
        chain.doFilter(request, response);
    }
}$code$),
    ('correlation-ids-and-request-context', 3, 'Logging discipline that pays off', $body$The value of correlation appears during incidents, so logging decisions should be made for that moment. Include the identifier in a consistent structured field so queries can filter on it, not buried in prose. Log decisions and state transitions with their inputs, and avoid logging full payloads that may contain personal data. In high-throughput services, guard expensive debug messages and prefer parameterised logging to avoid building strings that are discarded. Rule of thumb: if an engineer cannot reconstruct one request end to end from logs alone across services, the logging contract needs work before the next incident.$body$, $code$class MdcTaskDecorator implements TaskDecorator {
    public Runnable decorate(Runnable task) {
        Map<String, String> context = MDC.getCopyOfContextMap();
        return () -> {
            MDC.setContextMap(context);
            try { task.run(); } finally { MDC.clear(); }
        };
    }
}$code$),
    ('synchronous-vs-asynchronous-service-calls', 1, 'Temporal coupling is the real cost', $body$A synchronous call requires the callee to be available and fast at the exact moment the caller needs it, which couples their availability and latency. Chain five synchronous calls with ninety-nine percent availability each and the combined availability is roughly ninety-five percent, before any retry. Synchronous is the right default when the caller genuinely cannot proceed without the answer and the user is waiting for it. The problem starts when calls are synchronous only because they were easy to write. Rule of thumb: ask whether the caller needs the result now or merely needs it eventually, and let that answer choose the transport.$body$, $code$@PostMapping("/reports")
ResponseEntity<Void> request(@RequestBody ReportRequest request) {
    Job job = reportQueue.enqueue(request);
    return ResponseEntity.accepted()
        .location(URI.create("/reports/" + job.id()))
        .build();
}$code$),
    ('synchronous-vs-asynchronous-service-calls', 2, 'When a queue beats a call', $body$Asynchronous messaging decouples time: the producer hands off a durable message and continues, and the consumer processes at its own pace. That absorbs bursts, lets consumers restart without losing work, and removes the need for the producer to know consumer addresses. The cost is complexity: eventual consistency, duplicate delivery, ordering limits, dead-letter handling, and harder debugging. Use messaging for work that can complete later, for fan-out to several consumers, and for smoothing load. Rule of thumb: if the caller would only be waiting to satisfy a workflow, publish an event and let the interested service react.$body$, $code$public void placeOrder(OrderCommand command) {
    Order order = orders.save(Order.from(command));
    // Send after commit so consumers never see an uncommitted order
    outboundQueue.send(new OrderPlaced(order.id(), order.customerId()));
}$code$),
    ('synchronous-vs-asynchronous-service-calls', 3, 'Hybrid designs and request-reply', $body$Most systems need both. A common hybrid accepts a command synchronously, validates it, writes durable state, and returns a ticket or resource location with 202, then completes the work asynchronously and signals completion through a callback, a polled status endpoint, or an event. The synchronous part stays fast and the expensive part is decoupled. Keep a single source of truth for status, and give clients a bounded way to learn the outcome so they do not poll forever. Rule of thumb: be synchronous at the edge for validation and identity, asynchronous behind it for the work.$body$, $code$@GetMapping("/reports/{id}")
ResponseEntity<ReportStatus> status(@PathVariable long id) {
    return reports.status(id)
        .map(ResponseEntity::ok)
        .orElseGet(() -> ResponseEntity.accepted()
            .header(HttpHeaders.RETRY_AFTER, "5")
            .build());
}$code$),
    ('service-contract-evolution', 1, 'Consumer-driven contracts in CI', $body$A consumer-driven contract records what each consumer actually needs from a provider and verifies it in the provider pipeline. Tools such as Pact let consumers publish expectations that the provider replays against its real implementation, so incompatibilities fail a build rather than production. Contracts complement, not replace, integration tests: they prove the provider still satisfies known consumers but say nothing about unknown ones. Keep the contract small and about the interface, never about internal fields the consumer should not depend on. Rule of thumb: a provider may not merge a change that breaks a published contract without an agreed migration.$body$, $code${
  "consumer": { "name": "web-app" },
  "provider": { "name": "order-service" },
  "interactions": [{
    "description": "get an order",
    "request": { "method": "GET", "path": "/orders/42" },
    "response": { "status": 200, "body": { "id": 42, "status": "PLACED" } }
  }]
}$code$),
    ('service-contract-evolution', 2, 'Versioning policy and tolerant readers', $body$Prefer additive evolution: add optional fields, never repurpose existing ones, and make readers tolerant of unknown fields so old clients ignore additions. Breaking changes require a new version, exposed either in the path or through a media type, and both versions must run side by side until consumers migrate. Structural validation tools catch syntax, but only people can judge whether changed semantics still mean the same thing. Document which changes are safe in each direction for your serialisation format. Rule of thumb: version only when a consumer must change code, and keep the number of live versions small enough to test.$body$, $code$@JsonIgnoreProperties(ignoreUnknown = true)
record OrderView(long id, String status) {
    OrderView {
        Objects.requireNonNull(status);
    }
}$code$),
    ('service-contract-evolution', 3, 'Deprecation, telemetry, and sunsets', $body$Deprecation is a process, not an announcement. Signal it in the response with a Deprecation header and a Sunset header carrying the planned retirement date, link to migration documentation, and instrument per-consumer usage so you know who still calls the endpoint. Then communicate a timeline long enough for the slowest consumer, offer a migration path, and only remove the endpoint after traffic reaches zero or the agreed date arrives. Removing without telemetry is guesswork. Rule of thumb: no endpoint is removed until usage data shows the remaining callers are acceptable to break or have confirmed migration.$body$, $code$HTTP/1.1 200 OK
Deprecation: @1767225600
Sunset: Thu, 31 Dec 2026 00:00:00 GMT
Link: <https://api.example.com/docs/migrate-v2>; rel="deprecation"

HTTP/1.1 410 Gone
Content-Type: application/problem+json

{"title":"This endpoint was retired on 31 December 2026."}$code$),
    ('multi-tenancy-strategies', 1, 'Choosing an isolation model', $body$Shared schema tags every row with a tenant identifier: cheapest to operate, but a single missing filter leaks data across tenants. Schema per tenant gives stronger isolation and simpler per-tenant backup, while still sharing one database. Database per tenant gives the strongest separation, independent scaling, and residency control, at the cost of managing many instances and migrations. The choice is driven by regulatory requirements, noisy-neighbour tolerance, and how many tenants you expect. Rule of thumb: start with shared schema plus enforced row-level security, and move heavy or regulated tenants to dedicated schemas or databases when isolation requirements justify the operational cost.$body$, $code$ALTER TABLE invoice ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON invoice
    USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Each connection sets the tenant before serving a request
SET app.tenant_id = '3f2a8c14-9d6e-4b71-8a0c-5e2f7b9d1c34';$code$),
    ('multi-tenancy-strategies', 2, 'Noisy neighbours and per-tenant fairness', $body$In a shared deployment one tenant can consume most of the capacity. Protect against it with per-tenant rate limits, bulkheads, and quotas on expensive operations, and make limits visible to tenants so behaviour is predictable. Meter the work each tenant consumes, not just request counts, because one large query can cost more than thousands of small ones. Consider priority classes for tenants who pay for them, and make sure background jobs and batch imports cannot starve interactive traffic. Rule of thumb: every shared resource needs a per-tenant cap; unlimited sharing eventually becomes an outage for someone.$body$, $code$RateLimiter limiter = limiterRegistry.rateLimiter(
    "extract-" + tenantId,
    RateLimiterConfig.custom()
        .limitForPeriod(tenant.limit().requestsPerMinute() / 60)
        .limitRefreshPeriod(Duration.ofSeconds(1))
        .build());$code$),
    ('multi-tenancy-strategies', 3, 'Onboarding, migration, and lifecycle', $body$Tenancy decisions show up in operations. Adding a tenant may mean provisioning a schema, seeding reference data, routing configuration, and verifying that no shared cache key omits the tenant. Migrations must be applied to every tenant store in a controlled order, with a way to detect drift. Removing a tenant requires data export and deletion that satisfies retention rules, and residency requirements may forbid co-locating certain tenants at all. Rule of thumb: make tenant placement explicit configuration rather than an accident of which shard a request happened to reach.$body$, $code$class TenantRoutingDataSource extends AbstractRoutingDataSource {
    @Override
    protected Object determineCurrentLookupKey() {
        return TenantContext.current();
    }
}$code$),
    ('strangler-fig-migration', 1, 'Route seams behind a facade', $body$The strangler fig approach replaces a monolith incrementally: put a facade in front of the existing system, move one capability at a time to the new service, and route traffic through the facade so callers never learn about the split. Start with the least entangled capability so you learn the deployment and data patterns safely. The facade must support routing both ways, which also gives instant rollback when a newly extracted service misbehaves. The seam lives at a domain boundary, not at a database table. Rule of thumb: choose a slice that can deliver value alone; a slice that still needs deep monolith integration is not really separable.$body$, $code$spring:
  cloud:
    gateway:
      routes:
        - id: invoices-new
          uri: lb://invoice-service
          predicates:
            - Path=/invoices/**
            - Weight=invoices, 10
        - id: invoices-legacy
          uri: http://monolith
          predicates:
            - Path=/invoices/**
            - Weight=invoices, 90$code$),
    ('strangler-fig-migration', 2, 'Synchronising data during transition', $body$While both systems run, data must be consistent enough for correctness and reconciliation. Options include dual writes from the application, change data capture from the monolith database, or synchronous reads during the transition. Dual writes risk inconsistency when one side fails; change data capture adds throughput and ordering concerns but keeps the source authoritative; temporary synchronous calls keep correctness at the price of coupling. Whichever you pick, decide which system owns each fact, and build a reconciliation job that compares and repairs drift. Rule of thumb: there is always a backup plan for the data, and it must be tested before cutover, not during it.$body$, $code$SELECT legacy.id
FROM legacy_invoice legacy
FULL OUTER JOIN invoice current ON current.id = legacy.id
WHERE legacy.id IS NULL
   OR current.id IS NULL
   OR legacy.updated_at <> current.updated_at;$code$),
    ('strangler-fig-migration', 3, 'Retiring monolith code paths', $body$The migration is finished only when the old code paths are deleted. Track progress with measurable signals: percentage of traffic served by new services, remaining shared database access, and the count of monolith modules with no recent calls. Before removing a path, confirm no consumer depends on it, keep the facade rollback available, and archive logs and reports that finance or regulators still need. Delete dead code quickly, because leaving both implementations invites divergence and confusion about which is authoritative. Rule of thumb: schedule the deletion as part of the migration plan, and treat an unretired path as unfinished work with a named owner.$body$, $code$SELECT path, count(*) AS calls, max(occurred_at) AS last_seen
FROM access_log
WHERE path LIKE '/invoices/%'
GROUP BY path
ORDER BY last_seen DESC;$code$),
    ('microservices-anti-patterns', 1, 'Distributed monolith and shared databases', $body$A distributed monolith has the deployment complexity of microservices with the coupling of a monolith: services that must be released together, share a database schema, or make synchronous calls in long chains. Sharing a database is the most damaging symptom, because any service can read or lock another team tables, and schema changes become organisation-wide events. Fix it by assigning ownership: one service owns each table and exposes it through an interface, and others read through that interface or through replicated events. Rule of thumb: if two services cannot be deployed independently on a random Tuesday, they are one service wearing two names.$body$, $code$-- Two services, one table, independent release trains:
-- web-api writes order.status
-- billing-worker writes order.status
GRANT SELECT, UPDATE ON orders TO billing_worker;

-- Any column change now couples both release trains,
-- and neither team can migrate its schema alone.$code$),
    ('microservices-anti-patterns', 2, 'Chatty services and nanoservices', $body$Splitting aggressively produces services so small that a single user action requires many remote calls, each adding latency and a new failure mode. Networks are slower and less reliable than in-process calls, so fine-grained decomposition can make the whole system worse than the monolith it replaced. Related data that changes together usually belongs together, and a service should own a coherent capability rather than a single operation or entity. Coarsen boundaries, batch reads, and cache carefully. Rule of thumb: optimise for independent change and clear ownership, not minimum size.$body$, $code$// Chatty: one remote call per line item
for (Item item : items) {
    catalog.get(item.id());
}

// Coarse: one call for the whole order
catalog.get(new GetItemsRequest(itemIds));$code$),
    ('microservices-anti-patterns', 3, 'A pragmatic monolith-first stance', $body$Starting with a well-modularised monolith is a legitimate architectural choice, not a lack of ambition. It keeps transactions local, avoids premature distribution, and lets you discover real boundaries from usage before paying for network hops and operational tooling. Split when a concrete pressure appears: teams stepping on each other, scaling needs that differ by capability, or independent release requirements. Track those pressures explicitly so splitting is a decision, not a default. Rule of thumb: adopt microservices for organisational and scaling reasons you can name, and keep module boundaries clean so extraction remains possible later.$body$, $code$// Module boundaries inside the monolith: other modules call only this API
record BillingModule(InvoiceRepository invoices) {
    Invoice issue(Order order) {
        return invoices.save(Invoice.from(order));
    }
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
    'api-gateway-patterns', 'service-discovery-in-practice', 'centralised-configuration',
    'circuit-breaker-patterns', 'bulkheads-and-pool-isolation', 'retry-storm-prevention',
    'distributed-transactions-and-sagas', 'transactional-outbox-pattern',
    'idempotency-in-distributed-systems', 'distributed-tracing-in-java',
    'correlation-ids-and-request-context', 'synchronous-vs-asynchronous-service-calls',
    'service-contract-evolution', 'multi-tenancy-strategies', 'strangler-fig-migration',
    'microservices-anti-patterns'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
