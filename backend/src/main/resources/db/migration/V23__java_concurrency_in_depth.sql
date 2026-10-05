-- V23 — Java concurrency in depth.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('thread-lifecycle-and-diagnostics', 'Thread Lifecycle and Diagnostics', 'Trace thread states and read thread dumps to explain what a busy service is actually doing.', 'Junior', 24, true, 1),
    ('executor-service-patterns', 'Executor Service Patterns', 'Size pools, bound queues, and choose rejection policies that keep overload from becoming an outage.', 'Junior', 30, true, 1),
    ('future-and-completablefuture', 'Futures and CompletableFuture', 'Compose asynchronous results with clear failure handling instead of blocking on raw get calls.', 'Junior', 26, true, 1),
    ('thread-safety-by-design', 'Thread Safety by Design', 'Rely on confinement, immutability, and safe publication to make shared state safe before adding locks.', 'Mid', 28, true, 1),
    ('locks-vs-synchronized', 'Locks versus Synchronized', 'Compare intrinsic locks with ReentrantLock and use lock ordering to rule out deadlocks.', 'Mid', 32, true, 1),
    ('atomics-and-cas', 'Atomics and CAS Loops', 'Update shared counters with CAS retry loops, understand contention, and use LongAdder for hot paths.', 'Mid', 24, true, 1),
    ('concurrent-collections-in-practice', 'Concurrent Collections in Practice', 'Use ConcurrentHashMap, CopyOnWrite collections, and blocking queues for their real trade-offs.', 'Mid', 28, true, 1),
    ('virtual-threads-in-practice', 'Virtual Threads in Practice', 'Adopt virtual threads where they shine and avoid the pinning and pooling mistakes that waste them.', 'Mid', 32, true, 1),
    ('structured-concurrency-preview', 'Structured Concurrency Preview', 'Coordinate related subtasks as one unit and let cancellation propagate instead of leaking threads.', 'Senior', 38, true, 1),
    ('deadline-and-timeout-propagation', 'Deadline and Timeout Propagation', 'Carry one request deadline through every layer so callers fail fast instead of waiting per call.', 'Senior', 35, true, 1),
    ('threadlocal-and-context-propagation', 'ThreadLocal and Context Propagation', 'Use ThreadLocal and MDC without leaking state across pooled threads or oversized virtual threads.', 'Mid', 26, true, 1),
    ('deadlock-livelock-detection', 'Deadlock and Livelock Detection', 'Recognize deadlock conditions, detect them with tooling, and design rules that prevent them.', 'Senior', 40, true, 1),
    ('backpressure-and-flow-control', 'Backpressure and Flow Control', 'Bound work end to end so queues absorb bursts instead of amplifying overload.', 'Senior', 38, true, 1),
    ('async-vs-sync-tradeoffs', 'Async versus Sync Trade-offs', 'Choose between blocking threads and async orchestration based on workload, debugging cost, and failure behavior.', 'Mid', 30, true, 1),
    ('parallel-streams-and-forkjoin', 'Parallel Streams and ForkJoin', 'Understand the common pool, avoid blocking work inside parallel pipelines, and know when to avoid them.', 'Mid', 28, true, 1),
    ('testing-concurrent-code', 'Testing Concurrent Code', 'Write deterministic concurrency tests with latches, barriers, and stress loops instead of sleeps.', 'Senior', 42, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('thread-lifecycle-and-diagnostics', 1, 'Thread States and Transitions', $body$Java threads move through NEW, RUNNABLE, BLOCKED, WAITING, TIMED_WAITING, and TERMINATED as reported by `Thread.getState()`. RUNNABLE means the thread is eligible to run, not that it is on a CPU, so a thread blocked in a native socket read still shows RUNNABLE. BLOCKED specifically means waiting to enter a synchronized region, while WAITING covers `Object.wait`, `join`, and parks. Treat states as diagnostic hints from one instant, not as proof of progress. A healthy pool shows most workers parked in TIMED_WAITING; a shape with everything RUNNABLE can simply mean the service is busy rather than broken.$body$, $code$Thread worker = new Thread(() -> {
    try { Thread.sleep(50); } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    }
});
System.out.println(worker.getState()); // NEW
worker.start();
worker.join();
System.out.println(worker.getState()); // TERMINATED$code$),
    ('thread-lifecycle-and-diagnostics', 2, 'Reading Thread Dumps Under Load', $body$A thread dump is a snapshot of every thread stack, and reading it under load is a skill: capture two or three dumps a few seconds apart with `jcmd <pid> Thread.print` or `jstack`. Group threads by name prefix, count how many sit in the same frame, and compare dumps for stacks that never move. Since JDK 21, thread dumps include virtual threads, and `jcmd <pid> Thread.dump_to_file -format=json` produces machine-readable output for large fleets. Look for lock addresses repeated across BLOCKED threads, pools where every worker waits on the same future, and thread counts that grow without bound. One dump tells you where threads are; several tell you whether they are moving.$body$, $code$// Capture two or three dumps a few seconds apart during the incident:
//   jcmd <pid> Thread.print > dump-1.txt
//   jcmd <pid> Thread.dump_to_file -format=json dump.json
// Compare them: a stuck thread keeps the same frames and lock lines,
// while a merely slow thread changes stacks between dumps.$code$),
    ('thread-lifecycle-and-diagnostics', 3, 'Stuck Stack Signatures', $body$Most production incidents present recognizable stuck signatures. Many threads BLOCKED on one monitor address mean a hot lock or a deadlock cycle. Workers WAITING in `Future.get` suggest an executor whose tasks wait on each other. RUNNABLE threads deep in `socketRead` with flat stacks point at a dependency that stopped responding. A pair of threads each holding one lock and waiting for the other is the classic deadlock report from `jcmd`. Compare dumps before escalating: a thread that is merely slow changes stacks and state, while a stuck one repeats. Rule of thumb: if the same thread is in the same frame across three dumps minutes apart, treat it as stuck and inspect lock owners and downstream connections.$body$, $code$ThreadMXBean mx = ManagementFactory.getThreadMXBean();
long[] deadlocked = mx.findDeadlockedThreads();
if (deadlocked != null) {
    for (ThreadInfo info : mx.getThreadInfo(deadlocked, true, true)) {
        System.out.println(info);
    }
}$code$),
    ('executor-service-patterns', 1, 'Pool Sizing from Workload Shape', $body$Pool size comes from workload shape, not habit. For CPU-bound work, a small pool near the number of cores avoids context-switch overhead; extra threads only add contention. For work that blocks on I/O or locks, throughput depends on how much time tasks spend waiting, so you need enough threads to keep cores busy, bounded by the resources those tasks touch. `ThreadPoolExecutor` lets you set core and maximum sizes, keep-alive, a bounded queue, and a thread factory that names threads; named threads make dumps readable. Never grow a platform-thread pool to thousands: each thread costs stack memory and scheduler time. Measure queue wait and utilization, then adjust; sizing by guesswork hides overload instead of fixing it.$body$, $code$ThreadPoolExecutor pool = new ThreadPoolExecutor(
    4, 8, 60, TimeUnit.SECONDS,
    new ArrayBlockingQueue<>(200),
    r -> new Thread(r, "report-worker"));
pool.prestartAllCoreThreads();$code$),
    ('executor-service-patterns', 2, 'Bounded Queues and Rejection Policies', $body$`Executors.newFixedThreadPool` uses an unbounded queue, so submission never blocks and the backlog grows until latency or memory fails; treat that factory as a convenience for tests. Supply a `ThreadPoolExecutor` with an `ArrayBlockingQueue` and a deliberate rejection policy. `AbortPolicy` throws `RejectedExecutionException`, which you translate into a fast failure at the boundary. `CallerRunsPolicy` applies backpressure by making the submitting thread run the task, which can be right for batch producers and wrong when the caller holds locks or serves latency-sensitive requests. `DiscardPolicy` silently drops work and is almost never correct. Rule of thumb: queue capacity expresses how long you are willing to let work wait, so size it from the request latency budget.$body$, $code$ThreadPoolExecutor pool = new ThreadPoolExecutor(
    2, 2, 0, TimeUnit.SECONDS,
    new ArrayBlockingQueue<>(50));
try {
    pool.execute(task);
} catch (RejectedExecutionException e) {
    // Fail fast: the backlog is already deeper than the latency budget.
    throw new ServiceUnavailableException("report backlog full", e);
}$code$),
    ('executor-service-patterns', 3, 'Avoiding Unbounded Task Submission', $body$Bounding the pool does not bound the questions you accept: a bounded queue still lets producers submit faster than consumers finish until the queue fills, and then every submission fails. Decide the maximum number of live tasks with admission control such as a semaphore or a rate limiter, and reject early with a clear error while the system is still healthy. Do not create an executor per request or per tenant unless you shut it down and account for its threads. Split pools by workload so slow report jobs cannot occupy workers that serve interactive traffic. When work is purely blocking I/O at very high concurrency, virtual threads with a resource semaphore usually beat a large platform pool. Rule: limit outstanding work, not just worker count.$body$, $code$Semaphore inFlight = new Semaphore(64);
void handle(Request request) {
    if (!inFlight.tryAcquire()) {
        throw new ServiceUnavailableException("export limit reached");
    }
    try {
        executor.execute(() -> {
            try { export(request); } finally { inFlight.release(); }
        });
    } catch (RejectedExecutionException e) {
        inFlight.release();
        throw e;
    }
}$code$),
    ('future-and-completablefuture', 1, 'Compose Instead of Blocking', $body$`CompletableFuture` models a result that arrives later. Chain transformations with `thenApply`, dependent asynchronous calls with `thenCompose`, independent results with `thenCombine`, and fan-in with `allOf`. Each stage runs when its input completes; a stage that blocks a pooled thread delays every task behind it, so keep continuations free of `get()` and long I/O unless you explicitly hand them to another executor. Since Java 9 you can bound a chain with `orTimeout` or `completeOnTimeout`, but a timeout on a stage does not interrupt the work that is already running. Rule of thumb: compose all the way, and perform exactly one blocking join at the boundary of your request, never inside a stage.$body$, $code$CompletableFuture<Receipt> receipt =
    orderService.findOrder(orderId)             // CompletableFuture<Order>
        .thenCompose(order -> paymentClient.charge(order))
        .thenApply(charge -> Receipt.from(charge));
receipt.orTimeout(2, TimeUnit.SECONDS);
return receipt; // caller joins once at the edge$code$),
    ('future-and-completablefuture', 2, 'Handling Failures Deliberately', $body$Failures in a chain travel as `CompletionException` wrapping the original cause, and stages such as `thenApply` are skipped once an upstream stage fails. Recover with `exceptionally` when a default is safe, or with `handle` when you need both the value and the error to choose a branch; `whenComplete` observes without replacing the result. Always keep the underlying cause for logs and metrics, and never translate every failure into a generic default value, because that hides real outages. `allOf` fails as soon as any input fails but waits for the rest only when you call join. Rule of thumb: decide per stage whether an error is recoverable, and make the final stage produce either a domain result or a typed failure that callers can act on.$body$, $code$CompletableFuture<Quote> quote = pricingClient.quote(sku)
    .handle((value, error) -> {
        if (error != null) {
            log.warn("quote failed for {}", sku, error);
            return Quote.unavailable(sku);
        }
        return value;
    });$code$),
    ('future-and-completablefuture', 3, 'Blocking get Anti-Patterns', $body$`get()` without a timeout can block a request thread forever when a dependency stalls, and calling it inside another completion stage consumes pool threads while waiting, which can deadlock the pool that is supposed to complete the stage. Prefer `get(timeout, unit)` or `join` with a timeout at a single edge, and cancel work that is no longer useful; cancellation is cooperative, so tasks must check interrupts. When `get` throws `ExecutionException`, unwrap the cause instead of reporting a wrapper; when it throws `InterruptedException`, restore the interrupt flag and stop. Rule of thumb: one bounded blocking wait per request, at the outermost layer, with a deadline that accounts for the caller.$body$, $code$// Edge of the request only, always with a budget:
try {
    Quote quote = future.get(remainingBudgetMillis(), TimeUnit.MILLISECONDS);
    return respond(quote);
} catch (TimeoutException e) {
    future.cancel(false); // dependents stop; a running supplier is not interrupted
    throw new GatewayTimeoutException("pricing budget exceeded", e);
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
    throw new CancellationException("request interrupted");
}$code$),
    ('thread-safety-by-design', 1, 'Confinement and Local State', $body$The cheapest way to make state safe is to keep it out of sharing. Local variables live on one thread stack; an object referenced only by locals is confined to the thread that created it. Thread confinement also works at larger scale: build a result, then hand it to another thread through a queue and never touch it again, transferring ownership instead of sharing. `ThreadLocal` confines values deliberately, but pooled threads outlive requests, so values must be removed when the work ends. Do not publish a mutable object by storing it in a shared map and keeping your own reference. Rule of thumb: before adding synchronization, ask whether the state must be shared at all, then share an immutable snapshot rather than the mutable original.$body$, $code$// Snapshot is built and owned by this thread only; no sharing.
List<Invoice> snapshot = repository.loadPending(tenantId);
BigDecimal total = BigDecimal.ZERO;
for (Invoice invoice : snapshot) {
    total = total.add(invoice.amount());
}
queue.put(new Totals(tenantId, total)); // hand off immutable value$code$),
    ('thread-safety-by-design', 2, 'Immutability and Final Fields', $body$An immutable object never changes after construction, so it needs no coordination: any number of threads can read it. Make fields final, avoid setters, and never expose internal mutable collections; records give you concise carriers, but their mutable components still need defensive copies, for example `List.copyOf` on the way in and on the way out when elements are mutable. Final fields receive special initialization safety in the Java Memory Model, so properly constructed immutable objects can be read safely even when published through data races. Unmodifiable views are not copies: they still throw if the backing collection changes. Rule of thumb: default to immutable values, and model change by replacing the value rather than mutating it.$body$, $code$record AccountView(String id, List<String> roles) {
    AccountView {
        roles = List.copyOf(roles);   // copy on the way in
    }
}$code$),
    ('thread-safety-by-design', 3, 'Safe Publication of State', $body$Correctly synchronized construction is not enough; a reference must also be published safely. Storing a new object into a plain field that another thread reads without synchronization can expose a partially initialized object, because there is no happens-before edge. Publish through mechanisms that create one: a `final` field, a `volatile` field, `AtomicReference`, a static initializer, or while holding a lock. Never let `this` escape a constructor by registering callbacks, starting threads, or storing `this` in a shared container. Immutable objects published unsafely still risk stale reference visibility, though not torn internal state. Rule of thumb: initialize fully, publish once through a synchronized channel, and then treat the object as read-only forever.$body$, $code$final class Registry {
    private static final class Holder {
        static final Registry INSTANCE = new Registry();
    }
    static Registry instance() { return Holder.INSTANCE; }
}
// Alternative: publish through a volatile field or an AtomicReference.$code$),
    ('locks-vs-synchronized', 1, 'Intrinsic Locks and Their Limits', $body$Every object has an intrinsic monitor. `synchronized` methods and blocks acquire it, giving mutual exclusion plus visibility, because releasing a monitor happens-before a later acquire of the same monitor. The JVM releases monitors automatically, even on exceptions, which makes intrinsic locking hard to get wrong. The limits show under contention: acquisition cannot time out, cannot be interrupted, and offers no fairness control. Synchronizing on a public object, a string literal, or `getClass()` invites outside interference and unexpected sharing; lock on a private final lock object. Rule of thumb: use `synchronized` for short critical sections by default, and reach for explicit locks only when you need a capability intrinsic locks cannot provide.$body$, $code$private final Object lock = new Object();

boolean withdraw(long amount) {
    synchronized (lock) {
        if (balance < amount) return false;
        balance -= amount;
        return true;
    }
}$code$),
    ('locks-vs-synchronized', 2, 'ReentrantLock Features in Practice', $body$`ReentrantLock` offers what monitors cannot: `tryLock` with an optional timeout, `lockInterruptibly`, optional fairness, and multiple `Condition` objects so one lock can manage separate wait sets. Reentrancy counts acquisitions, so an unlock must match every successful lock; always unlock in a `finally` block. Fairness roughly honors arrival order at a throughput cost, so enable it only to fix observed starvation. Use `Condition.await` and `signal` instead of `Object.wait` and `notify` when you need several wait reasons on one lock. Rule of thumb: keep the simple intrinsic lock unless timeout, interruptibility, or conditions change the design; then use `ReentrantLock` and keep the lock scope as small as the invariant allows.$body$, $code$private final ReentrantLock lock = new ReentrantLock();

boolean withdraw(long amount) throws InterruptedException {
    if (!lock.tryLock(50, TimeUnit.MILLISECONDS)) {
        return false;   // bounded wait instead of indefinite block
    }
    try {
        if (balance < amount) return false;
        balance -= amount;
        return true;
    } finally {
        lock.unlock();
    }
}$code$),
    ('locks-vs-synchronized', 3, 'Lock Ordering and Granularity', $body$Deadlocks from locks usually come from inconsistent acquisition order: thread A holds account 1 and wants account 2 while thread B holds account 2 and wants account 1. Establish a global order, such as sorting by identifier, and follow it on every path. Never call external code, invoke listeners, or perform I/O while holding a lock, because the callee may acquire another lock and create an unforeseen cycle. Granularity is a trade-off: splitting one lock into several raises concurrency but multiplies ordering obligations; merging keys on one lock simplifies reasoning but serializes unrelated work. Where a cycle is possible, `tryLock` with backoff can break it. Rule of thumb: prefer coarse locks with short critical sections until contention proves you need finer ones.$body$, $code$// Every path acquires accounts in ascending id order.
Account first  = lowId < highId ? from : to;
Account second = lowId < highId ? to : from;
synchronized (first) {
    synchronized (second) {
        first.debit(amount);
        second.credit(amount);
    }
}$code$),
    ('atomics-and-cas', 1, 'CAS Retry Loops', $body$Compare-and-set changes a value only if it still holds the expected one, which makes single-variable updates atomic without a lock. The canonical loop reads the current value, computes the next one, and calls `compareAndSet`, retrying on failure. Under contention the loop can spin many times, consuming CPU while doing work that is thrown away, and the ABA problem can hide a value that changed to something else and back; stamped references detect that. Modern helpers such as `updateAndGet`, `getAndUpdate`, and `accumulateAndGet` apply a function atomically and are usually clearer than hand-written loops. Keep loop bodies pure: they may run more than once. Rule of thumb: use CAS for one variable, a lock for an invariant across several.$body$, $code$AtomicInteger retries = new AtomicInteger();

int nextAttempt() {
    int current;
    do {
        current = retries.get();
        if (current >= MAX_ATTEMPTS) {
            throw new RetryLimitExceededException();
        }
    } while (!retries.compareAndSet(current, current + 1));
    return current + 1;
}$code$),
    ('atomics-and-cas', 2, 'Choosing Atomics by Access Pattern', $body$Match the atomic to the pattern. `AtomicInteger` and `AtomicLong` suit counters, sequence numbers, and single-value state machines; `AtomicReference` swaps immutable snapshots for read-mostly state; atomic arrays update independent slots. Since Java 9, `VarHandle` provides similar operations on plain fields with selectable memory ordering, which is useful in framework code but rarely in application code. Two atomics are not atomic together: an invariant that spans several variables still needs a lock or a single reference to an immutable aggregate. Beware of `weakCompareAndSet`, which may fail spuriously, and of reads used in coordination, because a plain read has no memory ordering guarantees. Rule of thumb: one atomic per independent fact.$body$, $code$record ConnectionState(String host, boolean healthy) {}

AtomicReference<ConnectionState> state =
    new AtomicReference<>(new ConnectionState("db-1", true));

void markUnhealthy(String reason) {
    state.updateAndGet(current ->
        new ConnectionState(current.host(), false));
}$code$),
    ('atomics-and-cas', 3, 'Hot Counters and LongAdder', $body$`LongAdder` and `DoubleAdder` split a hot counter across cells, so contending threads update different cache lines and usually stop fighting. `sum()` walks the cells without locking, so it is not a linearizable snapshot and must not coordinate decisions; a concurrent update can also be missed. Under low contention adders behave much like atomics while using more memory, and each `sum` costs more as cell count grows, so read rarely and report periodically. Use `AtomicLong` when you need exact read-modify-write semantics such as unique sequence generation or state transitions. For histograms, combine an adder with `ConcurrentHashMap` keys. Rule of thumb: coordination and identity need atomics; metrics and statistics belong in adders.$body$, $code$LongAdder requests = new LongAdder();
LongAdder failures = new LongAdder();

void record(boolean ok) {
    requests.increment();
    if (!ok) failures.increment();
}

// Read for reporting only; sum() is not a coordination primitive.
double failureRatio = (double) failures.sum() / requests.sum();$code$),
    ('concurrent-collections-in-practice', 1, 'ConcurrentHashMap Usage Idioms', $body$`ConcurrentHashMap` is the default shared map, but its guarantees are per key: `computeIfAbsent`, `compute`, `merge`, and `putIfAbsent` run atomically for one key, while check-then-act sequences across calls are not safe. Mapping functions must be short, because they execute while a bin is locked, and they must not call back into the same map, or they can deadlock. Null keys and values are rejected, so absence and null need one representation. Iterators are weakly consistent: they never throw `ConcurrentModificationException` but may or may not reflect updates, and `size()` is an estimate under concurrency. Never use map-wide operations as coordination. Rule of thumb: express mutations as single atomic map operations, and keep user code out of compute functions.$body$, $code$ConcurrentHashMap<String, LongAdder> counts = new ConcurrentHashMap<>();

void record(String tenant) {
    counts.computeIfAbsent(tenant, key -> new LongAdder()).increment();
}
// The mapping function must be short: it runs inside the bin lock.$code$),
    ('concurrent-collections-in-practice', 2, 'CopyOnWrite Collection Trade-offs', $body$`CopyOnWriteArrayList` and `CopyOnWriteArraySet` copy the entire backing array on every write, so readers never block and iterators are stable snapshots. That makes them excellent for small, rarely changed, frequently read collections such as listener registries or feature flags, and terrible for large or write-heavy data, where copying burns CPU and allocation and can still lose concurrent edits because writes are serialized. Iteration over a snapshot may miss additions made after the iterator was created, which is usually acceptable for notification use cases. `addIfAbsent` scans the whole array per call, so registration paths should stay infrequent. Rule of thumb: copy-on-write for tiny read-mostly lists, `ConcurrentHashMap` or a queue when writes are common.$body$, $code$CopyOnWriteArrayList<Listener> listeners = new CopyOnWriteArrayList<>();

void onEvent(Event event) {
    for (Listener listener : listeners) {   // snapshot iterator, no lock
        listener.accept(event);
    }
}
// Writes copy the whole array: keep the list small and read-mostly.$code$),
    ('concurrent-collections-in-practice', 3, 'Blocking Queues for Handoff', $body$A blocking queue is the standard handoff between producer and consumer threads. `ArrayBlockingQueue` has a fixed capacity and a single lock; `LinkedBlockingQueue` optionally bounds capacity and uses separate locks; `SynchronousQueue` performs direct handoff with no storage and powers cached thread pools; `LinkedTransferQueue` combines handoff with buffering. Choose bounded capacity and decide the producer policy: block with `put`, wait with a bounded `offer`, or reject immediately. Blocking on the producer side converts overload into backpressure instead of unbounded memory. Consumers should use `poll` with timeouts so shutdown stays responsive, and shutdown signalling must handle an empty queue. Rule of thumb: never let a queue grow without a limit, and never use its `size` for control logic.$body$, $code$BlockingQueue<Task> queue = new ArrayBlockingQueue<>(100);

void submit(Task task) throws InterruptedException {
    if (!queue.offer(task, 200, TimeUnit.MILLISECONDS)) {
        throw new ServiceUnavailableException("handoff queue full");
    }
}$code$),
    ('virtual-threads-in-practice', 1, 'Task per Thread, Not Pooling', $body$Virtual threads are JDK-managed threads that unmount from their carrier platform threads whenever they block on I/O, so a service can keep millions of cheap threads instead of pooling. Use `Executors.newVirtualThreadPerTaskExecutor()`, which creates one virtual thread per task and holds no pool; the executor is lightweight and closable, and `close()` waits for submitted tasks. Converting a shared platform pool to virtual threads gains little unless you convert tasks, so represent each unit of work, including small fan-out subtasks, as its own thread. Virtual threads do not speed up CPU-bound work. Oracle suggests that if a service never needs ten thousand concurrent threads, it is unlikely to benefit. Rule of thumb: thread per task for blocking I/O, platform pools for compute.$body$, $code$try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    Future<Profile> profile = executor.submit(() -> loadProfile(userId));
    Future<Orders> orders = executor.submit(() -> loadOrders(userId));
    return new Page(profile.get(), orders.get());
}$code$),
    ('virtual-threads-in-practice', 2, 'Pinning and Synchronized Pitfalls', $body$When a virtual thread cannot unmount it is pinned, and its carrier is blocked with it. Historically the main cause was blocking inside `synchronized`; JDK 24 (JEP 491) changed monitor handling so blocking in synchronized regions unmounts, removing most pinning, but virtual threads still pin while blocked inside native frames or foreign function calls. Diagnose with JDK Flight Recorder events such as `jdk.VirtualThreadPinned`; the old `jdk.tracePinnedThreads` property was removed in JDK 24, so do not rely on it. Long blocking in native code can still starve carriers. Rule of thumb: keep native calls short, prefer `java.util.concurrent` locks in libraries that block, and check your exact JDK version before repeating pinning advice.$body$, $code$// JDK 24 removed pinning caused by synchronized (JEP 491).
// Remaining pinning: native frames or foreign function calls that block.
// Diagnose with JFR, not the removed trace property:
//   java -XX:StartFlightRecording ...
//   Event: jdk.VirtualThreadPinned$code$),
    ('virtual-threads-in-practice', 3, 'Bounding Resources Without Pooling', $body$Virtual threads make pool sizing for blocking I/O mostly irrelevant: you no longer pick a thread count to cap concurrency, because threads are cheap. You still must bound scarce resources. Wrap database connections, HTTP client connections, and file handles with semaphores or dedicated pools sized to the downstream capacity, and keep timeouts on every blocking call so abandoned work stops holding a permit. Do not pool virtual threads: a pool would reintroduce every queueing problem while adding nothing. Watch memory per task, because each task holds a stack-like object graph and queued tasks still retain memory. Rule of thumb: thread per task, permit per resource, and treat the number of concurrent tasks as the thing you control.$body$, $code$static final Semaphore DB_PERMITS = new Semaphore(20);

try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (Request request : batch) {
        executor.submit(() -> {
            DB_PERMITS.acquire();
            try { return repository.load(request); }
            finally { DB_PERMITS.release(); }
        });
    }
}$code$),
    ('structured-concurrency-preview', 1, 'Scoped Task Groups', $body$Structured concurrency keeps subtask lifetimes inside a lexical scope. `StructuredTaskScope` is a preview API (JEP 505 in JDK 25, changed across earlier previews, requiring `--enable-preview`): open a scope in try-with-resources, `fork` subtasks that run in virtual threads, then `join` them as one operation. The default scope succeeds only if all subtasks succeed and cancels the rest on the first failure; richer policies come from a `Joiner`. No subtask can outlive the block, so thread leaks and orphaned work disappear by construction. Verify the exact API shape against your JDK, because preview signatures differ between releases. Rule of thumb: use scopes for request-scoped fan-out, not for long-lived background work.$body$, $code$// Preview: requires --enable-preview. API shape may differ on your JDK.
try (var scope = StructuredTaskScope.open()) {
    Subtask<User> user = scope.fork(() -> findUser(userId));
    Subtask<List<Order>> orders = scope.fork(() -> findOrders(userId));
    scope.join();   // waits for both or cancels on first failure
    return new Profile(user.get(), orders.get());
}$code$),
    ('structured-concurrency-preview', 2, 'Automatic Cancellation Propagation', $body$Because a scope owns its subtasks, cancellation is automatic. If one subtask throws, the scope interrupts its siblings; if the owner thread is interrupted, exiting the scope cancels everything; a failed join reports the first failure as the cause and does not wait for unnecessary results. Subtasks must cooperate: code that ignores interrupts delays scope closure, and `close()` waits for interrupted threads, so an interruptible blocking call or an explicit interrupt check is required. Cancelled subtasks should clean up quickly and report only as needed. Rule of thumb: write subtask code as if it can be cancelled at any blocking point, and never swallow `InterruptedException`; restore the flag or propagate it so the scope can finish promptly.$body$, $code$try (var scope = StructuredTaskScope.open(
        Joiner.anySuccessfulResultOrThrow())) {
    scope.fork(() -> primary.lookup(key));
    scope.fork(() -> replica.lookup(key));
    String value = scope.join();   // fastest success wins
    return value;
}$code$),
    ('structured-concurrency-preview', 3, 'Relationship to Virtual Threads', $body$Structured concurrency and virtual threads solve different halves of the same problem: virtual threads make blocking cheap, and scopes make the resulting threads manageable. Forked subtasks run in virtual threads by default, which is why one scope per request is affordable, and observability tools can show the parent-child thread hierarchy. Scopes complement rather than replace `ExecutorService`; shared long-lived pools and background processors still need executors, while per-request fan-out belongs in a scope. Joiner policies cover patterns such as first-success and all-or-nothing. Because the API is still preview, isolate it behind small adapters in your code. Rule of thumb: adopt gradually, one fan-out site at a time, after pinning and interruption behavior is verified.$body$, $code$// Forked subtasks run in virtual threads by default.
// Keep long-lived, shared pools on ExecutorService; use scopes per request.
Response handle(Request request) throws Exception {
    try (var scope = StructuredTaskScope.open()) {
        Subtask<Auth> auth = scope.fork(() -> authService.verify(request));
        Subtask<Data> data = scope.fork(() -> dataService.load(request));
        scope.join();
        return new Response(auth.get(), data.get());
    }
}$code$),
    ('deadline-and-timeout-propagation', 1, 'One Deadline per Request', $body$Give every request a single absolute deadline, created once at the boundary from an injected `Clock`. Each layer derives its remaining budget by subtraction instead of carrying a fresh timeout, so a retry or a fan-out cannot multiply the worst-case latency: an 800 millisecond request with three 500 millisecond hops would otherwise take 1.5 seconds. Before starting expensive work, check that enough budget remains, and fail fast when it does not. Choose budgets from user expectations and dependency latency distributions, not from defaults. Never reset the clock mid-request. Rule of thumb: a request has exactly one deadline, and each operation receives the smaller of its configured limit and the remaining budget.$body$, $code$Instant deadline = clock.instant().plus(Duration.ofMillis(800));

Duration remaining() {
    Duration left = Duration.between(clock.instant(), deadline);
    if (left.isNegative() || left.isZero()) {
        throw new DeadlineExceededException();
    }
    return left;
}$code$),
    ('deadline-and-timeout-propagation', 2, 'Propagating Budget Through Layers', $body$Deadlines only work when they cross every boundary. Pass the deadline through method signatures or a request context, translate it to protocol features such as gRPC deadline headers or HTTP timeouts, and convert it at blocking calls with `get(remaining)` or `orTimeout(remaining)`. When the budget expires, cancel outstanding work instead of abandoning it, or you pay for results nobody will read. Timeouts must be shorter than the caller deadline, never equal to it, so the caller still has time to receive and handle the failure. Rule of thumb: propagate absolute deadlines, not per-hop durations; a hop that starts work it cannot finish wastes capacity for everyone.$body$, $code$Duration budget = remaining();
HttpRequest request = HttpRequest.newBuilder(uri)
    .timeout(budget)                       // never start work we cannot finish
    .header("X-Request-Deadline", deadline.toString())
    .GET()
    .build();
HttpResponse<String> response =
    client.send(request, HttpResponse.BodyHandlers.ofString());$code$),
    ('deadline-and-timeout-propagation', 3, 'Timeouts as First-Class Failures', $body$Treat deadline expiry as a distinct, observable outcome. Record which layer exhausted the budget, keep the original timeout alongside the request identifier, and do not retry past the deadline, because retries after expiry only add load for work the caller has abandoned. Distinguish a slow dependency from a caller-imposed budget exhaustion when alerting, since the fixes differ. Measure elapsed time with a monotonic clock such as `System.nanoTime`, because wall-clock adjustments make duration arithmetic unreliable, and inject `Clock` in tests to make time deterministic. Rule of thumb: if a worker discovers the deadline already passed, it should stop before doing the work and say so clearly in logs and metrics.$body$, $code$long startNanos = System.nanoTime();
try {
    return dependency.call(remaining());
} catch (TimeoutException e) {
    // Never retry past the deadline: the caller already gave up.
    throw new UpstreamTimeoutException("dependency exceeded budget", e);
} finally {
    long elapsedNanos = System.nanoTime() - startNanos;
    metrics.record("dependency.latency", elapsedNanos);
}$code$),
    ('threadlocal-and-context-propagation', 1, 'ThreadLocal Cost and Leaks', $body$`ThreadLocal` stores a value per thread and remains the standard tool for context that would otherwise cross every method signature. In pooled environments the danger is lifetime mismatch: a worker thread outlives the request, so a value left in the map leaks into the next request and pins its object graph; the key is weakly referenced, but a live thread keeps the value reachable. Always remove values in a `finally` block around the unit of work, and keep stored objects small. `InheritableThreadLocal` copies values only at thread creation, which is unreliable with pools. On virtual threads each thread has its own locals, so per-thread caches can consume surprising memory. Rule of thumb: set, use, and remove within one clearly bounded scope.$body$, $code$private static final ThreadLocal<RequestContext> CONTEXT = new ThreadLocal<>();

void filter(Request request, Runnable chain) {
    CONTEXT.set(new RequestContext(request));
    try {
        chain.run();
    } finally {
        CONTEXT.remove();   // pooled threads outlive requests
    }
}$code$),
    ('threadlocal-and-context-propagation', 2, 'MDC and Request Context', $body$The Mapped Diagnostic Context carries per-thread logging fields such as request and trace identifiers. It travels with the thread, so it is lost the moment work moves to an executor, and it contaminates the worker thread that runs the next task. Set MDC values at the request boundary, clear them in a `finally` block, and capture the map before submitting asynchronous work so each task can restore it. The same pattern applies to security contexts such as Spring Security, whose holder binds to the current thread, and to transaction or locale context. Prefer dedicated context-propagation libraries over hand-rolled wrappers where available. Rule of thumb: context must be captured at submit time and restored around execution, never inherited implicitly from a reused worker.$body$, $code$String traceId = request.header("X-Trace-Id");
MDC.put("traceId", traceId);
try {
    return handler.handle(request);
} finally {
    MDC.clear();   // async handoff does not inherit this map
}$code$),
    ('threadlocal-and-context-propagation', 3, 'Propagation into Pools and Virtual Threads', $body$Executors do not copy thread-local state for you: a task submitted to a pool sees whatever the worker thread happens to hold, so tasks must capture context at submission and restore it while running. Write one wrapper or decorator and apply it at the executor boundary rather than scattering `put` and `remove` calls. Virtual threads have their own `ThreadLocal` values and do not inherit from the submitting thread automatically, so per-request context still needs explicit carrying. Where you control the code, prefer passing context explicitly, or `ScopedValue` (final in JDK 25), which shares immutable data with child threads and cannot leak. Rule of thumb: context propagation is an explicit, tested mechanism, not a side effect of thread creation.$body$, $code$static <T> Callable<T> wrap(Callable<T> task, String traceId) {
    return () -> {
        MDC.put("traceId", traceId);
        try {
            return task.call();
        } finally {
            MDC.clear();
        }
    };
}$code$),
    ('deadlock-livelock-detection', 1, 'Deadlock Conditions and Signatures', $body$Deadlock requires four conditions at once: mutual exclusion, hold-and-wait, no preemption, and a circular wait. Breaking any one prevents it; in practice you break circular wait by ordering locks, or hold-and-wait by acquiring everything with timeouts. The signature is two or more threads blocked forever, each holding a resource the other needs: monitor owners appear as BLOCKED, `ReentrantLock` waiters as WAITING or TIMED_WAITING on parks, and a lock can also wait on a database row or an upstream call. Bugs often mix lock types, which is why tooling looks at monitors and ownable synchronizers separately. Rule of thumb: a deadlock is a design defect, so fix the ordering or scope rather than adding retries.$body$, $code$ThreadMXBean mx = ManagementFactory.getThreadMXBean();
long[] ids = mx.findDeadlockedThreads();   // monitors and locks
if (ids != null) {
    for (ThreadInfo info : mx.getThreadInfo(ids, true, true)) {
        alerting.raise("deadlock", info.toString());
    }
}$code$),
    ('deadlock-livelock-detection', 2, 'Detection Tooling in Practice', $body$`jcmd <pid> Thread.print` and `jstack` print a deadlock section naming the threads, the locks they own, and the stack frames of the cycle. `ThreadMXBean.findDeadlockedThreads()` detects deadlocks programmatically, so a watchdog can raise an alert before anyone files a ticket, and `getThreadInfo` with locked monitors shows owners. JDK Flight Recorder events such as `jdk.JavaMonitorEnter` and `jdk.ThreadPark` record contention history with the classes involved, which is useful after the fact. Because detection only sees deadlocks that are currently present, periodic dumps matter. Rule of thumb: run a deadlock watchdog in production, alert on it, and treat any report as actionable regardless of user impact.$body$, $code$// jcmd <pid> Thread.print        -> deadlock report with lock owners
// jcmd <pid> JFR.start duration=60s filename=lock.jfr
// Events: jdk.JavaMonitorEnter, jdk.ThreadPark show contention history.
// A watchdog that runs findDeadlockedThreads on a schedule catches
// production deadlocks that never produce an OOM.$code$),
    ('deadlock-livelock-detection', 3, 'Livelock and Starvation', $body$Livelock means threads keep doing work, retrying and backing off, without making progress, often because every participant reacts to contention in the same way. In the worst case, two threads repeatedly acquire different locks, detect a conflict, release, and collide again forever. Starve-resistant designs add jitter, randomize which lock is attempted first, and bound retries so failure is reported instead of spun; unfair locks can starve a thread indefinitely, so enable fairness only where starvation is observed. Starvation also comes from priority inversion or a hot path that always wins. Rule of thumb: an optimistic algorithm needs randomized backoff, an attempt limit, and a metric for unsuccessful attempts, or it silently converts contention into wasted CPU.$body$, $code$for (int attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    if (lock.tryLock()) {
        try { return apply(); }
        finally { lock.unlock(); }
    }
    sleepWithJitter(attempt);   // identical backoff = livelock
}
throw new LockTimeoutException();$code$),
    ('backpressure-and-flow-control', 1, 'Bound Work End to End', $body$Backpressure starts with arithmetic: concurrency equals throughput times latency, so a service that handles 200 requests per second at 50 milliseconds keeps about ten requests in flight; at 200 milliseconds it needs forty. Every queue, pool, and connection pool between request and response must be finite, and the smallest bound determines the system capacity. Adding workers does not help if a downstream dependency or database connection pool is the real bottleneck, because blocked workers still hold their own resources. Watch queue depth and, more importantly, queue age: depth tells you backlog exists, while age tells you whether work can still finish in time. Rule of thumb: bound every hop and choose the binding constraint deliberately.$body$, $code$// Every hop has a finite bound: pool, queue, and connection pool.
int maxInFlight = 64;
Semaphore admissions = new Semaphore(maxInFlight);

boolean admit() {
    return admissions.tryAcquire();   // reject instead of queueing forever
}$code$),
    ('backpressure-and-flow-control', 2, 'Queues as Shock Absorbers or Amplifiers', $body$A small queue absorbs short bursts and decouples producers from consumers; a deep queue under overload does the opposite. It hides the fact that demand exceeds capacity while latency climbs, tasks wait long enough for their deadlines to expire, and retries from impatient callers add still more work. When the queue fills, prefer failing fast at the producer with a clear error and a retry hint rather than growing memory or waiting indefinitely. Load shedding is a feature: serving most requests quickly beats serving all of them too late, and a rejection metric is a signal to scale or protect. Rule of thumb: if queue wait is visible to users, the queue is too deep or the workload should be rejected.$body$, $code$// Bounded queue of 50; never offer to an unbounded queue.
boolean submit(Task task) {
    if (!queue.offer(task)) {
        // Full queue means the backlog outlives the deadline.
        metrics.counter("tasks.rejected").increment();
        return false;
    }
    return true;
}$code$),
    ('backpressure-and-flow-control', 3, 'Backpressure in Reactive Systems', $body$Pull-based systems make flow control part of the protocol: Reactive Streams consumers request a bounded number of items, and operators such as `publishOn`, `concatMap`, and buffering operators respect that demand, so a slow consumer slows the producer instead of exhausting memory. The JDK `Flow` API defines the same shape, and frameworks such as Reactor and Mutiny implement it with operators for buffering, dropping, and sampling when producers cannot slow down. Message brokers use the pull model too: consumers poll when ready, with fetch limits. When a source cannot be slowed, give the buffer a bound and choose an explicit overflow strategy, such as dropping oldest data. Rule of thumb: propagate demand upstream, and treat every unbounded buffer as a defect.$body$, $code$Flux<Event> pipeline = source
    .onBackpressureBuffer(1_000, BufferOverflowStrategy.DROP_OLDEST)
    .publishOn(scheduler, 16)   // bounded prefetch requests demand upstream
    .concatMap(event -> handle(event), 8);
pipeline.subscribe(consumer);   // consumption drives demand upstream$code$),
    ('async-vs-sync-tradeoffs', 1, 'When Async Orchestration Wins', $body$Async orchestration pays off when one unit of work fans out into several independent remote calls, or when a service must hold tens of thousands of mostly idle connections. `CompletableFuture` composition and reactive pipelines let you join results without dedicating a thread to each wait, and patterns such as hedged requests or first-success races become natural. The win is concurrency with small thread counts and fine-grained cancellation. The cost is a state machine spread across callbacks and operators, where ordering, failure, and timeout interactions are harder to see. Choose async when fan-out and connection efficiency dominate the design, not merely because it sounds faster. Rule of thumb: async for concurrent composition of I/O, sync for straight-line logic around it.$body$, $code$CompletableFuture<Page> page =
    userClient.find(userId)
        .thenCombine(ordersClient.find(userId),
                     (user, orders) -> new Page(user, orders))
        .orTimeout(300, TimeUnit.MILLISECONDS);$code$),
    ('async-vs-sync-tradeoffs', 2, 'Cognitive and Debugging Cost', $body$Async code is harder to debug than it looks. A stack trace captured inside a callback ends at the executor or event loop, so you lose the request origin; thread dumps show pool threads executing unrelated continuations; breakpoints in an IDE do not follow a logical request across stages. Failure paths multiply, because every stage can time out, cancel, or complete after the caller gave up. Mitigations exist, including correlation identifiers, context propagation, tracing spans, and logging every boundary, but they are work you must budget for. Keep orchestration thin and push domain logic into synchronous, testable methods. Rule of thumb: if a team cannot explain a pipeline failure from its logs and traces quickly, the async layer is too large.$body$, $code$// A stack trace inside thenApply shows the pool thread, not the caller.
// Correlate every async boundary with a request id captured at submit time:
String requestId = currentRequestId();
executor.execute(() -> {
    log.info("handling {}", requestId);
});$code$),
    ('async-vs-sync-tradeoffs', 3, 'Choosing per Workload', $body$Choose per workload rather than per project. CPU-bound work belongs in bounded thread pools sized near the core count. Blocking I/O at high concurrency is usually best expressed as simple synchronous code on virtual threads with permits guarding scarce resources. Heavy fan-out, streaming, and many concurrent downstream calls favor async or reactive pipelines, especially where cancellation must be precise. Mixed systems keep a synchronous domain core and apply async only at the edges. Decide with tail latency and failure behavior, not only average throughput, and be prepared to run both approaches behind the same interface. Rule of thumb: default to synchronous code that a newcomer can follow, and introduce async where measurements justify it.$body$, $code$// CPU-bound: fixed pool sized to cores.
ExecutorService cpu = Executors.newFixedThreadPool(cores);

// Blocking I/O: one virtual thread per task, resources bounded by semaphore.
try (var io = Executors.newVirtualThreadPerTaskExecutor()) {
    io.submit(() -> blockingCall());
}$code$),
    ('parallel-streams-and-forkjoin', 1, 'Common Pool Mechanics', $body$Parallel streams execute on the shared `ForkJoinPool.commonPool`, whose target parallelism defaults to `Runtime.getRuntime().availableProcessors() - 1`; its threads are daemons, shared by the whole JVM, and used by every parallel stream that does not specify a pool. Fork-join splits recursive work into tasks, and idle workers steal tasks from busy queues, which keeps cores busy for CPU-bound bulk work. Because the pool is global, one pipeline full of blocked tasks can stall unrelated parallel work, and its parallelism can be changed only through a system property with JVM-wide effect. Rule of thumb: treat the common pool as a shared CPU resource, use parallel streams for compute, and never rely on it for latency isolation.$body$, $code$ForkJoinPool common = ForkJoinPool.commonPool();
System.out.println(common.getParallelism());  // processors - 1 by default

long total = IntStream.range(0, n).parallel()
    .filter(this::isPrime)
    .count();$code$),
    ('parallel-streams-and-forkjoin', 2, 'Blocking Work Inside Parallel Streams', $body$Blocking inside a parallel stream is the classic mistake: a task that waits on I/O, a lock, or another future occupies a common-pool thread, and enough blocked tasks starve the pool for every other user in the JVM. There is no compensation mechanism for arbitrary blocking in stream operations. If blocking is unavoidable, run the pipeline in a dedicated `ForkJoinPool`, submitted with `pool.submit(() -> stream...)`, but understand that you have only isolated the damage; the better fix is to do I/O with executors or virtual threads and keep streams for transformation and aggregation. Also avoid shared mutable accumulators and `forEach` side effects, which introduce races. Rule of thumb: parallel streams for stateless CPU work only.$body$, $code$// Do not block inside a parallel stream: common pool threads stall globally.
List<Data> loaded = ids.parallelStream()
    .map(id -> blockingClient.fetch(id))   // starves unrelated work
    .toList();

// Isolate if blocking is unavoidable, and bound the work:
ForkJoinPool pool = new ForkJoinPool(8);
List<Data> safe = pool.submit(() -> ids.parallelStream()
    .map(blockingClient::fetch).toList()).join();$code$),
    ('parallel-streams-and-forkjoin', 3, 'When to Avoid Parallel Streams', $body$Avoid parallel streams when the input is small, because splitting and merging overhead exceeds any gain; when the work is I/O-bound; when the operation depends on encounter order or mutates shared state; and when the service is latency-sensitive, since another tenant of the common pool can delay your pipeline. Nested parallel streams and parallel `forEach` with side effects are also warning signs. Prefer explicit executors when you need control over pool size, error handling, cancellation, and observability, and measure before and after: fork-join helps repeated CPU-heavy transforms over large collections, not every loop. Rule of thumb: default to sequential streams, and choose parallel only after profiling shows a CPU-bound hotspot that decomposes cleanly.$body$, $code$// CPU-bound bulk math with no shared state and no blocking: good fit.
long matches = values.parallelStream().filter(this::matches).count();

// Latency-sensitive or tiny inputs: sequential is usually faster.
long sequentialMatches = 0;
for (String value : values) {
    if (matches(value)) sequentialMatches++;
}$code$),
    ('testing-concurrent-code', 1, 'Deterministic Coordination with Latches', $body$Good concurrency tests control timing instead of hoping. `CountDownLatch` starts a group of workers simultaneously or waits for them to finish; `CyclicBarrier` synchronizes phases; `Phaser` manages multiple rounds. Wait for a bounded time with an assertion so a broken test fails instead of hanging, and assert invariants such as exact totals after joining. Test the unhappy paths too: interruption, cancellation, timeouts, and rejection behavior are where concurrency bugs live. Keep the tested unit small enough that its invariants are checkable, and prefer deterministic executors when the test does not need real parallelism. Rule of thumb: every concurrency test should express which interleaving it creates on purpose rather than relying on chance.$body$, $code$CountDownLatch ready = new CountDownLatch(4);
CountDownLatch start = new CountDownLatch(1);
for (int i = 0; i < 4; i++) {
    executor.submit(() -> {
        ready.countDown();
        start.await();      // release all workers at once
        counter.increment();
        return null;
    });
}
assertTrue(ready.await(1, TimeUnit.SECONDS));
start.countDown();
executor.shutdown();
assertTrue(executor.awaitTermination(1, TimeUnit.SECONDS));$code$),
    ('testing-concurrent-code', 2, 'Stress and Interleaving', $body$A single successful run proves almost nothing about thread safety; the failure may need a rare interleaving. Run the operation many times with several threads, varying counts and inputs, and assert invariants after each round. `@RepeatedTest` makes looping trivial; tools such as jcstress exercise memory-model edges with thousands of interleavings and are worth adopting for lock-free code. Stress tests are probabilistic, so keep them in CI with a fixed budget: a fast version on every build and a longer soak nightly. When a failure appears, reduce threads and iterations until it reproduces, then fix the design rather than loosening the assertion. Rule of thumb: stress testing complements deterministic tests, it does not replace them.$body$, $code$@RepeatedTest(200)
void incrementsAreNeverLost() {
    LongAdder counter = new LongAdder();
    runConcurrently(8, () -> counter.increment());
    assertEquals(8L, counter.sum());
}$code$),
    ('testing-concurrent-code', 3, 'Avoiding Flaky Sleeps', $body$`Thread.sleep` is the wrong synchronization primitive: on a loaded CI machine 100 milliseconds may be too short, and on an idle one it wastes time; tests become both slow and unreliable. Instead, count down a latch when the event happens, or poll a condition with a bounded timeout using a helper such as Awaitility, and assert that the condition was observed. Avoid asserting exact wall-clock timing, and make assertions independent of scheduling order. When a timeout is expected, assert the timeout path explicitly rather than sleeping past it. If a test still hangs, capture a thread dump before failing. Rule of thumb: synchronize on events and state, never on elapsed time, and let every wait have a deadline.$body$, $code$// Flaky: assumes the background task finishes within 100 ms.
Thread.sleep(100);
assertTrue(queue.isEmpty());

// Deterministic: wait for the event with a generous fail-fast timeout.
await().atMost(Duration.ofSeconds(2)).until(queue::isEmpty);$code$)
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
    'thread-lifecycle-and-diagnostics', 'executor-service-patterns',
    'future-and-completablefuture', 'thread-safety-by-design',
    'locks-vs-synchronized', 'atomics-and-cas',
    'concurrent-collections-in-practice', 'virtual-threads-in-practice',
    'structured-concurrency-preview', 'deadline-and-timeout-propagation',
    'threadlocal-and-context-propagation', 'deadlock-livelock-detection',
    'backpressure-and-flow-control', 'async-vs-sync-tradeoffs',
    'parallel-streams-and-forkjoin', 'testing-concurrent-code'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
