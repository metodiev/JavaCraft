-- V29 — Reactive and streaming engineering.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('reactive-programming-mental-model', 'The Reactive Programming Mental Model', 'Model data as streams of events over time and understand why nothing runs until a subscriber arrives.', 'Mid', 28, true, 1),
    ('reactor-core-fundamentals', 'Reactor Core Fundamentals', 'Work with Mono, Flux, and immutable operator pipelines that stay lazy until subscription.', 'Mid', 30, true, 1),
    ('reactor-backpressure-in-practice', 'Backpressure in Reactor in Practice', 'Apply request semantics and overflow policies that keep fast producers from exhausting memory.', 'Senior', 40, true, 1),
    ('reactor-error-handling', 'Error Handling in Reactor', 'Recover, translate, and retry failures correctly while respecting terminal error signals.', 'Mid', 32, true, 1),
    ('reactor-context-and-threading', 'Reactor Context and Threading', 'Carry contextual state across threads and choose schedulers that match each workload.', 'Senior', 38, true, 1),
    ('blocking-code-in-reactive-pipelines', 'Blocking Code in Reactive Pipelines', 'Isolate unavoidable blocking calls so they never stall event loop threads.', 'Senior', 36, true, 1),
    ('spring-webflux-fundamentals', 'Spring WebFlux Fundamentals', 'Build non-blocking HTTP services with annotated controllers or functional routes and pick between WebFlux and MVC.', 'Mid', 34, true, 1),
    ('webflux-testing-with-stepverifier', 'Testing WebFlux with StepVerifier', 'Verify reactive behavior signal by signal with StepVerifier, virtual time, and error assertions.', 'Senior', 34, true, 1),
    ('r2dbc-and-reactive-persistence', 'R2DBC and Reactive Persistence', 'Use R2DBC drivers and reactive repositories while respecting different transaction semantics.', 'Senior', 40, true, 1),
    ('reactive-http-clients', 'Reactive HTTP Clients', 'Compose WebClient calls with pooled connections and explicit timeouts at production scale.', 'Lead', 42, true, 1),
    ('reactive-vs-virtual-threads', 'Reactive versus Virtual Threads', 'Decide between reactive pipelines and virtual threads using workload shape and operational constraints.', 'Senior', 38, true, 1),
    ('streaming-data-with-kafka-and-reactor', 'Streaming Data with Kafka and Reactor', 'Consume Kafka reactively with explicit acknowledgement, retry boundaries, and realistic backpressure limits.', 'Lead', 42, true, 1),
    ('reactive-observability-and-debugging', 'Reactive Observability and Debugging', 'Diagnose reactive failures with checkpoint, controlled logging, and operator-level metrics.', 'Senior', 36, true, 1),
    ('migrating-mvc-to-webflux', 'Migrating from MVC to WebFlux', 'Move services from MVC to WebFlux incrementally without rewriting the domain or freezing delivery.', 'Senior', 38, true, 1),
    ('reactive-anti-patterns', 'Reactive Anti-Patterns', 'Recognize the misuse patterns that turn reactive code into silent bugs and operational risk.', 'Lead', 40, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('reactive-programming-mental-model', 1, 'Streams over time, not calls', $body$A reactive chain describes how values flow as signals over time rather than a single request-response call. Each operator declares a transformation of onNext, onError, and onComplete events, and nothing executes while the chain is merely assembled: results exist only between subscription and termination. In production this changes what you reason about, because latency, cancellation, and failure become properties of the flow, not of one method call. The common pitfall is treating a cold pipeline as a value holder that already contains data. Model the sequence of events, decide how it ends, and remember that a stream has no answer until someone subscribes.$body$, $code$Flux<PriceUpdate> updates = priceFeed.stream(symbol)
    .filter(update -> update.changePercent() > 1.0)
    .map(update -> update.withSource("alerting"))
    .take(Duration.ofMinutes(5));

Disposable running = updates.subscribe(
    update -> alerts.publish(update),
    error -> log.error("feed failed", error));$code$),
    ('reactive-programming-mental-model', 2, 'Declarative composition over control flow', $body$Operators such as map, filter, merge, and zip describe composition, not step-by-step execution order. Each stage should be a pure function of the signals it receives, so the whole chain can be reasoned about, tested, and reused without threading concerns. Declarative composition scales to concurrency without explicit locks because Reactor owns the coordination, not your code. The pitfall is nesting increasingly clever chains until nobody can say what runs when, or hiding shared mutable state inside lambdas. If a stage needs shared mutable state, the model is fighting you: restructure the flow instead of reaching for synchronization.$body$, $code$Mono<Quote> quote = pricingClient.fetch(symbol)
    .timeout(Duration.ofMillis(300))
    .onErrorReturn(Quote.unavailable(symbol));

Mono<Invoice> invoice = quote.zipWith(taxClient.rate(region),
    (q, rate) -> Invoice.from(q, rate));$code$),
    ('reactive-programming-mental-model', 3, 'Nothing happens until subscription', $body$Assembling a Flux or Mono only builds a recipe. The work starts when a subscriber subscribes, and every subscription replays the recipe independently, which is why a method returning Mono does nothing if nothing subscribes and why one reused instance can run its work twice. Production teams are regularly surprised by both directions: fire-and-forget paths silently skip work, while shared publishers duplicate it. Treat publishers as functions from subscriber to events: check that every terminal path actually subscribes, and prefer explicit subscription at the edge of the request rather than inside helpers. If each subscriber must see identical results, cache or share deliberately.$body$, $code$Mono<Receipt> receipt = orderService.checkout(order); // nothing ran

receipt.subscribe(r -> log.info("checkout {}", r.id())); // now it runs

Mono<Receipt> cached = receipt.cache(); // one run, replayed to many$code$),
    ('reactor-core-fundamentals', 1, 'Mono for one, Flux for many', $body$Mono models at most one value or an error, while Flux models zero to many values, and both end with either onComplete or onError. Neither type implies a value exists: Mono<Order> may complete empty, which is different from a nullable Order. Choose the narrower type that expresses cardinality, because callers can widen a Mono with flux() but cannot recover one value from a Flux without collecting. The pitfall is converting everything to Flux early and losing the contract that tells readers a single result is expected. Pick Mono for single results and completion signals, Flux for streams, and let the type document the cardinality.$body$, $code$Mono<Order> one = orderRepository.findById(id);
Flux<Order> many = orderRepository.findByCustomer(customerId);

Mono<Void> acknowledged = auditService.record(id);

Flux<Order> widened = one.flux();$code$),
    ('reactor-core-fundamentals', 2, 'Operators transform without mutating pipelines', $body$Every Reactor operator returns a new publisher that wraps the previous one, so the original pipeline is never mutated. map is a synchronous one-to-one transformation, flatMap is an asynchronous one-to-many transformation, and each stage observes only the signals of its upstream. Because pipelines are immutable values, you can store, reuse, decorate, and test them, and you can derive variants without touching the shared base. The pitfall is expecting an operator call to change an existing variable, or sharing one heavily decorated pipeline whose operators carry per-caller state. Build pipelines like values and derive each variant.$body$, $code$Flux<Order> base = repository.findOpenOrders();

Flux<OrderSummary> summarized = base
    .filter(Order::isOverdue)
    .map(OrderSummary::from);

Flux<Order> firstTen = base.take(10);$code$),
    ('reactor-core-fundamentals', 3, 'Laziness as the default contract', $body$Most sources and operator chains do nothing until subscription: fromIterable, HTTP calls, and database queries all stay inactive, so assembling a pipeline is free and safe. That laziness lets you compose behavior ahead of time, attach error handling, and hand the same publisher to several subscribers. It also means the code that builds a pipeline is not the code that runs it, and closures capture whatever the assembly site could see. The pitfall is capturing a stale snapshot in a field and expecting fresh data per request. Build pipelines inside request scope, close over immutable inputs, and never assume work happened just because a publisher was returned.$body$, $code$Mono<User> user = Mono.fromCallable(() -> repository.load(id));

Mono<User> worker = user
    .map(this::enrich);

// Two independent runs, not one shared value.
worker.subscribe();
user.map(this::otherPath).subscribe();$code$),
    ('reactor-backpressure-in-practice', 1, 'Request n defines the flow contract', $body$Reactive Streams defines demand as request(n): a subscriber asks upstream for a bounded number of items, and the publisher delivers at most that many until more is requested. Reactor propagates demand through operators when they support it, buffers when they cannot, and treats unbounded demand as a valid but dangerous choice. A subscribe() with no bounds asks for everything, which turns a fast producer into unbounded memory unless the source is naturally finite. The pitfall is assuming that wrapping a source in Flux automatically protects consumers. Put a limit such as limitRate at every boundary where production and consumption rates can diverge.$body$, $code$Flux<Message> inbound = queue.receive()
    .limitRate(32)
    .onBackpressureBuffer(1000);

inbound.publishOn(Schedulers.single(), 16)
    .subscribe(this::handle);$code$),
    ('reactor-backpressure-in-practice', 2, 'Buffer, drop, or keep latest', $body$When downstream demand lags, you must choose what happens to the excess: onBackpressureBuffer holds items and risks growing memory, onBackpressureDrop discards anything beyond demand, and onBackpressureLatest keeps only the newest value. Latency-sensitive displays and telemetry often want latest, while billing and audit paths must not silently lose data and should slow the producer instead. A bounded buffer that fails on overflow is safer than an unbounded one because failure is visible and local rather than fatal to the process. Pick the loss policy deliberately, make drops observable, and alert when they start happening in production.$body$, $code$sensorReadings
    .onBackpressureBuffer(5000,
        dropped -> log.warn("dropped reading {}", dropped),
        BufferOverflowStrategy.DROP_OLDEST)
    .subscribe(display::show);$code$),
    ('reactor-backpressure-in-practice', 3, 'Backpressure is negotiated, not guaranteed', $body$Backpressure is a cooperation protocol, not a guarantee. Time-driven sources such as interval, user input events, and many message brokers cannot be slowed, so they will keep producing regardless of demand. Protocols add their own limits: a WebSocket connection has finite buffering, and a Kafka consumer can pause between polls but not while parked too long without risking rebalance timeouts. The pitfall is trusting operators to protect a service whose upstream ignores demand. Bound every queue, define what is shed first, and treat queue depth as a first-class signal that pages someone before memory does.$body$, $code$Flux<Long> ticks = Flux.interval(Duration.ofMillis(10)); // ignores demand

ticks.onBackpressureDrop(t -> log.warn("tick dropped {}", t))
    .publishOn(Schedulers.single(), 16)
    .subscribe(this::processTick);$code$),
    ('reactor-error-handling', 1, 'onErrorResume and onErrorMap compared', $body$onErrorResume replaces a failed upstream with another publisher, while onErrorMap translates an exception into a domain-specific type. Both react only to the error signal, and neither can recover a sequence that already terminated, because an error ends the stream. Use onErrorMap at architectural boundaries so callers see stable exception types and causes remain attached, and use onErrorResume only when a real alternative exists, such as a cache or a default. The pitfall is swallowing failures with an empty fallback that hides outages. Recover with a meaningful value, or let the error travel with the context needed to diagnose it.$body$, $code$Mono<Report> report = reportClient.fetch(id)
    .onErrorMap(WebClientRequestException.class,
        ex -> new ReportUnavailableException(id, ex))
    .onErrorResume(ReportUnavailableException.class,
        ex -> reportCache.find(id));$code$),
    ('reactor-error-handling', 2, 'Retries must be idempotent and bounded', $body$retry(n) resubscribes upstream when an error arrives, up to n times, which replays the whole pipeline including side effects, so retried operations must be idempotent. retryWhen(Retry.backoff(...)) adds delay, jitter, and a predicate so that only transient failures retry and the schedule stops before a deadline. Retries amplify load exactly when a dependency is struggling, so unbounded or immediate retries can turn a brief blip into an outage. The pitfall is retrying validation or authorization failures whose outcome will not change. Retry only idempotent work, only on error types known to be transient, always with a cap and backoff.$body$, $code$Retry retry = Retry.backoff(3, Duration.ofMillis(200))
    .jitter(0.5)
    .filter(ex -> ex instanceof TimeoutException);

Mono<Quote> quote = pricingClient.fetch(symbol)
    .retryWhen(retry)
    .timeout(Duration.ofSeconds(3));$code$),
    ('reactor-error-handling', 3, 'Errors terminate the entire sequence', $body$An error is a terminal signal: it travels downstream, cancels upstream work, and no further onNext signals follow, which is why partial results are not a recovery mechanism inside one sequence. doOnError observes failures and handles nothing; it must never be mistaken for a fallback. Keep error objects meaningful by preserving causes, adding the operation identifier, and avoiding wrappers that discard the original stack. The pitfall is treating a failed Flux as resumable mid-stream and continuing with half-processed state. Design compensation around the subscription boundary, and let the subscriber decide whether to retry the whole operation.$body$, $code$Mono<Void> run = batch.process(items)
    .doOnError(ex -> log.error("batch {} failed", batch.id(), ex))
    .onErrorResume(ex -> deadLetter.park(batch.id(), ex).then())
    .then();

run.subscribe();$code$),
    ('reactor-context-and-threading', 1, 'Context replaces ThreadLocal across boundaries', $body$ThreadLocal cannot be trusted across reactive boundaries because an operator may execute on any scheduler thread, and the thread that continues a chain is often not the one that started it. Reactor Context is immutable state attached to the subscription: it is written with contextWrite near the subscriber and read with deferContextual or handleContext near the values that need it. It is the right home for tenant identity, correlation IDs, and security context. The pitfall is calling contextWrite in the middle of a chain and expecting upstream operators to see it, since context flows from bottom to top. Write it last, read it closest to the use.$body$, $code$Mono<Order> order = repository.findById(id)
    .flatMap(o -> Mono.deferContextual(ctx -> {
        String tenant = (String) ctx.get("tenantId");
        return audit.record(o, tenant).thenReturn(o);
    }));

order.contextWrite(Context.of("tenantId", tenantId)).subscribe();$code$),
    ('reactor-context-and-threading', 2, 'subscribeOn starts work, publishOn moves it', $body$subscribeOn affects where subscription and source execution happen, no matter where it appears in the chain, and when it is used more than once only the choice closest to the source matters. publishOn switches every signal downstream of its position onto the given scheduler and can be placed repeatedly to hop between contexts. Without either operator, each stage runs on the thread left by the previous one. The pitfall is reaching for publishOn to move a blocking source, which cannot work because the blocking call already happened upstream. Use subscribeOn for the source and publishOn for one specific downstream stage.$body$, $code$Flux<Row> rows = Flux.fromIterable(loadAll())
    .subscribeOn(Schedulers.boundedElastic())
    .publishOn(Schedulers.parallel())
    .map(this::transform);

rows.subscribe(renderer::write);$code$),
    ('reactor-context-and-threading', 3, 'Pick a scheduler by workload', $body$Match the scheduler to the resource the work consumes. Schedulers.parallel() is for short CPU-bound tasks and has as many workers as CPU cores, so blocking on it throws IllegalStateException because those threads are marked non-blocking. Schedulers.boundedElastic() is for blocking and legacy drivers, capping threads at ten times the CPU cores with a large task queue. Schedulers.single() serializes one-off work, and immediate() runs on the caller thread. The pitfall is running CPU-heavy work on boundedElastic or assuming elastic means unlimited. Choose the scheduler from the workload, and reuse shared instances instead of creating new ones per call.$body$, $code$Scheduler blocking = Schedulers.newBoundedElastic(40, 100_000, "legacy-db");

Mono<User> user = Mono.fromCallable(() -> jdbc.load(id))
    .subscribeOn(blocking)
    .publishOn(Schedulers.parallel());$code$),
    ('blocking-code-in-reactive-pipelines', 1, 'Blocking the event loop kills throughput', $body$A Netty event loop owns many connections with very few threads, so one blocking handler stalls every connection assigned to that loop: the delay spreads from one request to all of them, and the whole server degrades. Blocking is not only sleep: synchronized JDBC, file access, DNS resolution, and lock contention all park the thread. This is why blocking the event loop kills throughput rather than merely slowing one caller, and why a service that passes tests with a single user can collapse under real concurrency. No blocking call may run on an event-loop or parallel scheduler thread, and the framework will not detect it for you.$body$, $code$// Never on a Netty event loop: blocks the loop for everyone.
String body = httpClient.get(url).block();

// Blocking work is pushed to a scheduler built for it.
Mono.fromCallable(() -> jdbcTemplate.queryForList(sql))
    .subscribeOn(Schedulers.boundedElastic());$code$),
    ('blocking-code-in-reactive-pipelines', 2, 'Wrapping blocking calls with boundedElastic', $body$The standard bridge for unavoidable blocking code is Mono.fromCallable plus subscribeOn(Schedulers.boundedElastic()), which runs the call on a bounded elastic thread and returns signals to the caller context. boundedElastic caps its thread count and queues excess tasks, so sustained blocking degrades predictably instead of exhausting the machine. In a Flux of blocking calls, use flatMap with an explicit concurrency limit or limitRate so the scheduler queue does not flood. The pitfall is wrapping every element with unbounded concurrency and calling it reactive. Wrap at the smallest boundary, bound parallelism, and watch the scheduler queue depth in production.$body$, $code$Flux<Customer> customers = Flux.fromIterable(ids)
    .flatMap(id -> Mono.fromCallable(() -> jdbc.find(id))
        .subscribeOn(Schedulers.boundedElastic()), 8);

customers.subscribe(this::sendToIndexer);$code$),
    ('blocking-code-in-reactive-pipelines', 3, 'Keep blocking visible and temporary', $body$Isolating blocking work is a migration tool, not an end state. Prefer a non-blocking driver when one exists, and treat every wrapped blocking call as tracked debt with an owner and a removal trigger, because each one consumes a bounded thread that another request could need. Make violations visible: assert in tests that blocking runs only on allowed schedulers, and watch for IllegalStateException from block() on non-blocking threads. Legitimate exceptions exist, such as bootstrap and shutdown code where no reactive contract is active yet. Keep blocking inside small, bounded, observable adapters, and document why each one is still there.$body$, $code$Mono<Config> config = Mono.fromCallable(legacy::loadConfig)
    .subscribeOn(Schedulers.boundedElastic())
    .timeout(Duration.ofSeconds(2))
    .doOnSubscribe(s -> log.info("legacy bootstrap"));

config.subscribe(this::applyConfig);$code$),
    ('spring-webflux-fundamentals', 1, 'Annotated controllers versus functional routes', $body$WebFlux supports the annotated model, where @RestController methods return Mono and Flux, and a functional model, where RouterFunction maps requests to HandlerFunction. Both run on the same non-blocking runtime, and choosing between them is about expressiveness rather than performance. Annotated controllers are familiar and read well for CRUD-shaped APIs; functional routes make composition, filters, and small services explicit. The pitfall is believing annotations imply blocking semantics, or that WebFlux forces one model. Either way, handlers should only assemble a publisher and return; the framework subscribes and writes the response, so the work happens inside the reactive chain.$body$, $code$@GetMapping("/orders/{id}")
Mono<Order> one(@PathVariable String id) {
    return orderRepository.findById(id);
}

@GetMapping("/orders")
Flux<Order> all() {
    return orderRepository.findAll();
}$code$),
    ('spring-webflux-fundamentals', 2, 'Handlers assemble, they do not execute', $body$WebFlux reads request bodies as a Publisher and writes response bodies from a Publisher, so streaming works end to end: chunks flush as they are produced, and client cancellation propagates back upstream through the operators and into the driver. A handler should therefore be pure assembly that returns quickly, delegating all real work to the pipeline it builds. The pitfall is collecting a large body into memory inside a handler, which brings back the cost the stack was chosen to avoid. Keep handlers thin, stream instead of collecting, and let the server manage the connection lifecycle.$body$, $code$Flux<OrderEvent> stream(String customerId) {
    return eventRepository.tail(customerId)
        .timeout(Duration.ofMinutes(30))
        .map(OrderEventModel::from);
}$code$),
    ('spring-webflux-fundamentals', 3, 'Choosing WebFlux or Spring MVC', $body$Choose WebFlux when the workload is I/O-bound, highly concurrent, or streaming, and when the whole path, including drivers and outbound clients, can stay non-blocking. Choose Spring MVC when persistence is JPA or JDBC, when the team benefits from familiar imperative debugging, or when virtual threads already provide the concurrency needed. WebFlux does not make slow code fast, and it raises stack-trace and onboarding costs. Require a concrete reason such as connection-count limits, streaming contracts, or cancellation semantics, and reject a switch based only on perceived modernity. The simplest stack that meets the requirement is usually the right one.$body$, $code$@Bean
RouterFunction<ServerResponse> routes(OrderHandler handler) {
    return route()
        .GET("/orders/{id}", handler::get)
        .build();
}$code$),
    ('webflux-testing-with-stepverifier', 1, 'Assert signals step by step', $body$StepVerifier subscribes to a publisher and compares every signal with the next expectation: expectNext for values, expectNextCount for batches, expectComplete and expectError for termination, assertNext for custom assertions. This makes ordering, completion, and error timing part of the test rather than something inferred from a materialized value. It also reports the exact unexpected signal, which is far more useful than a generic assertion failure. The pitfall is calling block() in the test and asserting the value, which hides ordering and error behavior. Encode the expected signal sequence, then call verify with a timeout so a hung pipeline fails fast.$body$, $code$StepVerifier.create(service.recentOrders(customerId))
    .expectNextMatches(o -> o.customerId().equals(customerId))
    .expectNextCount(2)
    .expectComplete()
    .verify(Duration.ofSeconds(5));$code$),
    ('webflux-testing-with-stepverifier', 2, 'Virtual time without real waiting', $body$StepVerifier.withVirtualTime replaces the scheduler clock so delayElements, timeout, and interval resolve instantly: tests that would wait seconds run in milliseconds and stay deterministic. Pass a supplier so the pipeline is created inside the virtual-time context, use thenAwait to advance the clock, and use expectNoEvent to assert that nothing happens during a window. The pitfall is mixing real sleeps with virtual time, which reintroduces flakiness and defeats the purpose. Any test that depends on time-based operators should use virtual time unless it is specifically validating scheduler behavior.$body$, $code$StepVerifier.withVirtualTime(() ->
        Flux.interval(Duration.ofSeconds(1)).take(3))
    .expectSubscription()
    .expectNoEvent(Duration.ofMillis(900))
    .thenAwait(Duration.ofMillis(200))
    .expectNext(0L)
    .thenCancel()
    .verify();$code$),
    ('webflux-testing-with-stepverifier', 3, 'Assert error type and message', $body$Assert errors by type and message with expectError or expectErrorMatches, and inspect with expectErrorSatisfies when the exception needs deeper checks than equality. verifyThenAssertThat additionally exposes dropped elements and cancellation, so leaking operators can be tested. ContextKey seeds Reactor Context in a StepVerifier so contextual branches are exercised rather than assumed. The pitfall is asserting that some error occurred without checking which one, which passes when the service returns the wrong failure. Always assert the error type plus the message or cause, and cover the empty-completion path separately from the error path.$body$, $code$StepVerifier.create(service.load("missing"))
    .expectErrorMatches(ex -> ex instanceof NotFoundException
        && ex.getMessage().contains("missing"))
    .verify();

StepVerifier.create(limited.take(1))
    .expectNextCount(1)
    .thenCancel()
    .verify();$code$),
    ('r2dbc-and-reactive-persistence', 1, 'Why JDBC blocks and R2DBC does not', $body$JDBC is synchronous: a thread waits for the database and stays busy for the whole statement and result set, which is why JPA and JDBC adapters cannot be made truly non-blocking. R2DBC is a non-blocking SPI over the same wire protocols whose operations return publishers, so connections are held per in-flight statement rather than per parked thread. The benefit is lower thread pressure and better behavior when many requests wait on a slow database. The pitfall is adopting R2DBC when database latency, not thread count, is the real problem, because SQL does not get faster. Confirm the bottleneck before taking on this complexity.$body$, $code$// Blocking: one thread parked per statement.
List<Order> orders = jdbcTemplate.query(sql, mapper);

// Reactive: demand-driven results on the event loop.
Flux<Order> reactive = databaseClient.sql(sql)
    .map(mapper)
    .all();$code$),
    ('r2dbc-and-reactive-persistence', 2, 'Explicit queries instead of persistence contexts', $body$Spring Data R2DBC offers repository abstractions returning Mono and Flux but deliberately omits a persistence context: there is no lazy loading, no dirty checking, and no cascade, so data comes from explicit queries and joins. That constraint keeps fetching behavior visible and makes accidental N+1 patterns harder to hide, which is a genuine advantage at scale. The pitfall is expecting JPA relationship semantics and discovering them missing in production code paths. Design around explicit queries, project only the columns you need, and let repository methods express the read shape.$body$, $code$interface OrderRepository extends ReactiveCrudRepository<Order, Long> {
    Flux<Order> findByCustomerId(String customerId);
}

Flux<Order> orders = repository.findByCustomerId(id);$code$),
    ('r2dbc-and-reactive-persistence', 3, 'Reactive transaction semantics differ', $body$R2DBC transactions differ from JPA in important ways. With @Transactional or TransactionalOperator, everything inside the transactional boundary must share the same connection, so concurrent database calls within one transaction are not possible and work must not be forked onto other schedulers. Each subscription gets its own connection binding, and nested calls join the ambient transaction rather than opening one. The pitfall is parallelizing queries for speed inside a transaction and silently breaking atomicity or corrupting connection state. Keep transactions short, linear, and entirely on the reactive path.$body$, $code$@Transactional
public Mono<Order> place(Order order) {
    return orderRepository.save(order)
        .then(paymentRepository.save(paymentFor(order)))
        .thenReturn(order);
}$code$),
    ('reactive-http-clients', 1, 'WebClient pipelines compose and stream', $body$WebClient builds request pipelines returning Mono or Flux: retrieve for the common case, exchangeToMono when status-dependent handling is needed, and bodyToFlux for streaming responses. Because it is a publisher, it composes naturally with timeouts, retries, and fallbacks in the same chain as the rest of the service. It can also be called from Spring MVC, which makes it a good incremental adoption step. The pitfall is treating it as RestTemplate with a Mono wrapper and blocking at the end with block() or toFuture(), which wastes the stack. Keep calls reactive through the chain and convert at the boundary only when a caller demands it.$body$, $code$Mono<Order> order = webClient.get()
    .uri("/orders/{id}", id)
    .retrieve()
    .onStatus(HttpStatusCode::is5xxServerError,
        response -> Mono.error(new UpstreamException(id)))
    .bodyToMono(Order.class)
    .timeout(Duration.ofMillis(800));$code$),
    ('reactive-http-clients', 2, 'Timeouts, pools, and client lifecycle', $body$Configure and reuse one WebClient per dependency because each instance owns its connection pool and its connectors. Set connect, response, and read timeouts separately instead of one global value, since they fail in different ways and at different layers. Reactor Netty pools are bounded: when maxConnections is reached, requests wait up to pendingAcquireTimeout rather than opening new connections, so pool size and acquire time become production tuning parameters. The pitfall is building a client per request, leaking connectors, sockets, and threads. Share the client, tune the pool, and expose pool metrics.$body$, $code$ConnectionProvider pool = ConnectionProvider.builder("orders")
    .maxConnections(200)
    .pendingAcquireTimeout(Duration.ofMillis(500))
    .build();

HttpClient http = HttpClient.create(pool)
    .responseTimeout(Duration.ofSeconds(2));$code$),
    ('reactive-http-clients', 3, 'WebClient versus HTTP interface clients', $body$Spring MVC declarative HTTP interfaces with @HttpExchange produce type-safe clients that support reactive return types without exposing pipeline mechanics, which fits mostly imperative codebases and teams that value simple call sites. WebClient remains the stronger choice for streaming responses, dynamic headers, and deep composition with retries and fallbacks, and it works in both stacks. What matters more than the choice is centralizing cross-cutting behavior, so every caller inherits the same timeouts, retries, and metrics instead of reinventing them per call site. The pitfall is mixing both styles for one dependency and getting inconsistent failure behavior. Pick one abstraction per dependency and document it.$body$, $code$interface PricingApi {
    @GetExchange("/prices/{symbol}")
    Mono<Price> price(@PathVariable String symbol);
}

PricingApi api = HttpServiceProxyFactory
    .forWebClient(webClient).createClient(PricingApi.class);$code$),
    ('reactive-vs-virtual-threads', 1, 'Loom changes the I/O calculus', $body$Virtual threads change the economics of blocking I/O. A virtual thread per request costs little, the carrier pool stays small, and ordinary try/catch code keeps the debugging experience teams already know. For request-response services that spend their time waiting on JDBC, REST, or messaging, this removes the main historical reason to adopt reactive plumbing, and a property such as spring.threads.virtual.enabled makes it a one-line experiment. The pitfall is assuming virtual threads accelerate CPU work or remove the need for pool limits, because the database still has finite connections. Start imperative on virtual threads and measure before adding reactive types.$body$, $code$try (ExecutorService workers = Executors.newVirtualThreadPerTaskExecutor()) {
    var futures = ids.stream()
        .map(id -> workers.submit(() -> client.fetch(id)))
        .toList();
    awaitResults(futures);
}$code$),
    ('reactive-vs-virtual-threads', 2, 'Where reactive still clearly wins', $body$Reactive still wins where the workload is a stream rather than a call. Long-lived connections such as server-sent events, WebSockets, and database change streams benefit from composable cancellation and protocol-level flow control, and backpressure lets a saturated consumer signal the producer instead of queueing without bound. Reactive also fits pipelines that combine many asynchronous sources with retries, timeouts, and fallbacks in one place, because the operators already implement those combinations. The pitfall is adopting reactive for a couple of endpoints while a thread pool and blocking driver remain underneath. Choose reactive when flow control and cancellation are part of the contract.$body$, $code$// Thousands of long-lived streams: reactive carries flow control.
Flux<Comment> live = commentStream.forCustomer(customerId)
    .limitRate(64)
    .timeout(Duration.ofMinutes(10));

live.subscribe(serverSentEvents::send);$code$),
    ('reactive-vs-virtual-threads', 3, 'A decision framework on four axes', $body$Decide with four axes: workload shape, bottleneck, team fluency, and debuggability. Workload shape asks whether the endpoint is a call or a stream. Bottleneck asks whether threads, connections, or memory are actually exhausted, since virtual threads neutralize the first and reactive helps with the others. Team fluency covers how quickly the team can review and operate the code. Debuggability covers stack traces, tracing, and local reproduction under pressure. Mixed stacks are legitimate, for example WebClient inside virtual-thread MVC. The pitfall is rewriting working services for purity. Let evidence and the team decide, then record the rationale.$body$, $code$enum StackChoice { REACTIVE, VIRTUAL_THREADS, MVC }

StackChoice choose(Workload workload, boolean needsStreaming) {
    if (needsStreaming) return StackChoice.REACTIVE;
    return workload.ioBound() ? StackChoice.VIRTUAL_THREADS
                              : StackChoice.MVC;
}$code$),
    ('streaming-data-with-kafka-and-reactor', 1, 'Acknowledgement controls commit progress', $body$Reactor Kafka turns a consumer into a Flux of records, each carrying a receiver offset. With manual acknowledgement, the offset is committed only after processing succeeds, giving at-least-once delivery: a crash between processing and commit redelivers the record, so handlers must be idempotent. Acknowledging an offset implicitly covers all earlier offsets on that partition, which is efficient, but it also means one slow or skipped record holds back commit progress for everything behind it. The pitfall is acknowledging on receipt or processing asynchronously without tying the ack to completion. Acknowledge after the work is durably done.$body$, $code$Flux<ReceiverRecord<String, Order>> stream = receiver.receive();

stream.concatMap(record -> handle(record.value())
        .doOnSuccess(v -> record.receiverOffset().acknowledge()))
    .subscribe();$code$),
    ('streaming-data-with-kafka-and-reactor', 2, 'Messaging backpressure has hard limits', $body$Kafka consumers are pull-based, so polling limits in-flight records and demand does translate into respectful broker pauses, unlike push protocols such as WebSocket. The boundaries are real though: a partition cannot be slowed without stalling its siblings in the same subscription, pausing too long risks rebalance timeouts, and a reactive wrapper does not let you slow producers who keep publishing. Deadlines come from configuration choices such as prefetch sizes and commit intervals rather than from downstream demand alone. The pitfall is assuming backpressure means a pipeline can never overproduce. Size in-flight work, bound internal queues, and plan for rebalances.$body$, $code$ReceiverOptions<String, Order> options = ReceiverOptions
    .<String, Order>create(props)
    .subscription(List.of("orders"))
    .commitInterval(Duration.ofSeconds(2))
    .maxDeferredCommits(100);$code$),
    ('streaming-data-with-kafka-and-reactor', 3, 'Terminal errors stop the consumer', $body$Any error in the receive Flux is terminal: it cancels the subscription and shuts the consumer down, so an unhandled deserialization failure can silently stop an application. Wrap the stream with retryWhen so a new consumer is created, and isolate failures at the record level so one poison message does not stop a partition. Route unprocessable records to a dead-letter topic with headers that explain the failure, and alert on both stream restarts and dead-letter volume. The pitfall is catching and ignoring per-record errors with nothing recorded. Retry at the stream boundary, isolate at the record boundary, and make both visible.$body$, $code$receiver.receive()
    .flatMap(record -> process(record)
        .onErrorResume(ex -> deadLetter.send(record, ex))
        .then(Mono.fromRunnable(record.receiverOffset()::acknowledge)))
    .retryWhen(Retry.backoff(5, Duration.ofSeconds(1)));$code$),
    ('reactive-observability-and-debugging', 1, 'Stack traces across asynchronous boundaries', $body$When an error crosses an asynchronous boundary, the stack trace shows reactor internals and assembly-time frames instead of the operator that actually failed, so the useful information is missing exactly when it is needed. ReactorDebugAgent from reactor-tools or Hooks.onOperatorDebug() captures assembly information so traces point at pipeline construction, but full debug mode is expensive and belongs in tests or short diagnostic windows. The pitfall is enabling operator debug everywhere and paying for it in throughput, or shipping without it and guessing during an incident. Instrument deliberately, diagnose, then remove the instrumentation.$body$, $code$// Temporary diagnosis only: assembly cost is high.
Hooks.onOperatorDebug();

Mono<Order> order = repository.findById(id)
    .map(this::enrich);$code$),
    ('reactive-observability-and-debugging', 2, 'checkpoint, log, and tag discipline', $body$checkpoint attaches a description and a stack trace snapshot to the nearest upstream error and is cheap enough to keep on production paths, which is why it belongs at service boundaries rather than everywhere. log prints all signals for one stage and is useful in tests and short investigations, but it is noisy under load and a bare call uses a shared logger. tag adds key-value metadata that appears in debug output and Micrometer metrics. The pitfall is sprinkling log calls and calling the result observability. Keep checkpoints permanently, add logs temporarily, and use tags to connect reactive failures to the metrics around them.$body$, $code$Mono<Order> order = orderRepository.findById(id)
    .checkpoint("order-enrich")
    .tag("stage", "enrich")
    .onErrorMap(ex -> new OrderLookupException(id, ex));

order.subscribe(this::respond);$code$),
    ('reactive-observability-and-debugging', 3, 'Metrics at meaningful boundaries', $body$reactor-core-micrometer instruments a pipeline with subscription, request, and latency meters through Micrometer.metrics(registry), while name and tag give meters stable identities and dimensions. Instrument boundaries that correspond to business operations, not every operator, or overhead and metric cardinality grow without adding insight. Combine Reactor metrics with downstream client metrics and queue depth so saturation is visible before users notice it. The pitfall is dashboards that show request latency but nothing about where time is spent or where demand is piling up. Instrument boundaries, keep tag cardinality low, and alert on depth and latency together.$body$, $code$Mono<Order> order = orderRepository.findById(id)
    .name("orders.lookup")
    .tag("operation", "lookup")
    .tap(Micrometer.metrics(registry));

order.subscribe(this::respond);$code$),
    ('migrating-mvc-to-webflux', 1, 'Migrate edges before the core', $body$Migrate at the edges before the core. The first step is using WebClient for outbound calls inside an existing MVC application, which composes well with retries and timeouts and does not require changing controllers. Convert streaming endpoints next, where reactive behavior pays for itself, and move whole services only when drivers and downstream clients can stay non-blocking. Keeping domain and service logic framework-free lets both stacks share it during the transition. The pitfall is a big-bang rewrite that freezes feature delivery and buries regressions inside migration noise. Move one vertical slice at a time behind an unchanged API contract.$body$, $code$// MVC controller can return reactive types today.
@GetMapping("/orders")
Flux<OrderModel> orders() {
    return orderClient.streamOrders();
}$code$),
    ('migrating-mvc-to-webflux', 2, 'Share domain, adapt infrastructure', $body$A service layer shared by both stacks must not block reactive callers or hand publishers to imperative ones without an adapter. Keep pure domain logic shared, and adapt infrastructure per stack: transactions, security context propagation, and error translation all differ between MVC and WebFlux and should not be assumed portable. The pitfall is a transactional object assuming a ThreadLocal-bound transaction when it is called from a reactive path, which fails in ways that are hard to reproduce. Share the domain, adapt the edges, and forbid bridging the two models by blocking on a shared code path.$body$, $code$Mono<Feed> reactiveFeed(String id) {
    return feedClient.stream(id);
}

Feed blockingFeed(String id) {
    return reactiveFeed(id).block(Duration.ofSeconds(2));
}$code$),
    ('migrating-mvc-to-webflux', 3, 'Parity evidence before traffic shift', $body$Keep contract tests running against both stacks to prove parity before and after each slice, because framework differences show up in header handling, error mapping, and transaction behavior rather than in the domain code. Feature flags or parallel deployments let you shift traffic gradually and compare latency and error rates against the old path. The pitfall is assuming semantic equivalence and discovering differences only under production traffic. Require parity evidence first, shift traffic second, and keep the previous implementation runnable until the new one has carried real load through a full release cycle.$body$, $code$interface OrderApiContract {
    @GetExchange("/orders/{id}")
    Mono<OrderModel> get(@PathVariable String id);
}

// Run the same contract tests against old and new implementations.$code$),
    ('reactive-anti-patterns', 1, 'Subscribing inside operators', $body$Subscribing inside map, flatMap, or a constructor starts a second pipeline whose results and errors bypass the outer chain: failures vanish into an unobserved subscription, cancellation does not propagate, and tests never see the work. Only the consumer at the edge of the application should subscribe; every operator, service, and helper inside should return a publisher and let the caller decide when to run it. Fire-and-forget side effects belong in doOnNext or in an explicitly detached sink with its own error policy and metrics. The pitfall is subscribing because returning a Mono feels awkward at the call site. One subscription at the edge, publishers everywhere inside.$body$, $code$Mono<Void> publishWrong(Event e) {
    sender.send(e).subscribe();   // the error disappears here
    return Mono.empty();
}
Mono<Void> publishRight(Event e) {
    return sender.send(e);
}$code$),
    ('reactive-anti-patterns', 2, 'Blocking in map and unused Flux', $body$Two mistakes appear repeatedly in review: blocking inside map, which parks an event-loop thread and burns the throughput of every connection on it, and assembling a pipeline that nothing subscribes to, so the work silently never runs. A third cousin returns a Flux from a method whose caller expects a value, hiding the missing subscription behind type errors or empty results. Ask two questions of every reactive change: who subscribes, and what thread may each stage block on. If either answer is unclear, the pipeline is not ready. The pitfall is assuming code ran because it compiled.$body$, $code$Mono<Report> report = Mono.fromCallable(this::build)
    .map(this::render);

// save() blocks: move it behind boundedElastic.
Mono<Void> stored = report.flatMap(r -> Mono.fromCallable(() -> jdbc.save(r))
    .subscribeOn(Schedulers.boundedElastic()));$code$),
    ('reactive-anti-patterns', 3, 'Reactive for CRUD without a reason', $body$Converting a simple CRUD service to WebFlux adds mental overhead, weakens tooling such as JPA and blocking profilers, and rarely improves latency when database calls dominate. Most such services are better on MVC, especially with virtual threads, which deliver the concurrency that reactive abstraction was once needed for. The cost of a needless conversion lands in onboarding, stack traces, and debugging under incident pressure, not in the happy path. Require a concrete driver: streaming, cancellation, flow control, or connection counts that virtual threads cannot solve. Prefer the simplest stack that meets the requirement, and revisit only with measurements.$body$, $code$@GetMapping("/orders/{id}")
Order get(@PathVariable Long id) {
    return repository.findById(id)
        .orElseThrow(() -> new OrderNotFoundException(id));
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
    'reactive-programming-mental-model', 'reactor-core-fundamentals',
    'reactor-backpressure-in-practice', 'reactor-error-handling',
    'reactor-context-and-threading', 'blocking-code-in-reactive-pipelines',
    'spring-webflux-fundamentals', 'webflux-testing-with-stepverifier',
    'r2dbc-and-reactive-persistence', 'reactive-http-clients',
    'reactive-vs-virtual-threads', 'streaming-data-with-kafka-and-reactor',
    'reactive-observability-and-debugging', 'migrating-mvc-to-webflux',
    'reactive-anti-patterns'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
