-- V22 — Java performance engineering.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('java-performance-methodology', 'Java Performance Methodology', 'Measure before changing anything: define the metric, form a hypothesis, change one variable, and re-measure with evidence.', 'Mid', 28, true, 1),
    ('profiling-cpu-hotspots', 'Profiling CPU Hotspots', 'Find real CPU cost with sampling profilers and flame graphs, and separate compute-bound code from lock waits.', 'Senior', 34, true, 1),
    ('memory-profiling-in-practice', 'Memory Profiling in Practice', 'Diagnose heap growth with dumps and allocation profiles, telling leaks apart from ordinary allocation churn.', 'Senior', 36, true, 1),
    ('gc-tuning-in-practice', 'GC Tuning in Practice', 'Read garbage collection logs, choose between pause and throughput goals, and recognize when tuning cannot fix the problem.', 'Senior', 38, true, 1),
    ('jit-compilation-and-warmup', 'JIT Compilation and Warmup', 'Understand the tiered compilation path, why cold runs lie, and how warmup behaves in containers and short-lived replicas.', 'Senior', 33, true, 1),
    ('throughput-vs-latency', 'Throughput Versus Latency', 'Treat throughput and latency as separate goals, where batching helps one and hurts the other, and tails amplify across fan-out.', 'Senior', 30, true, 1),
    ('load-test-driven-tuning', 'Load-Test-Driven Tuning', 'Design load tests around real traffic shape, choose open or closed models deliberately, and read steady state instead of peaks.', 'Senior', 34, true, 1),
    ('database-performance-tuning', 'Database Performance Tuning', 'Triage slow queries by evidence, verify that indexes serve the plan, and balance connection pools against database capacity.', 'Senior', 40, true, 1),
    ('jdbc-and-pool-tuning', 'JDBC and Pool Tuning', 'Size connection pools from measured hold times, set timeouts that fail inside the caller budget, and reuse prepared statements.', 'Senior', 32, true, 1),
    ('serialization-performance', 'Serialization Performance', 'Understand where serialization time goes, when streaming beats tree models, and how to avoid encoding the same payload twice.', 'Lead', 35, true, 1),
    ('string-performance-java', 'String Performance in Java', 'Reduce string overhead with measured interning, deduplication, better concatenation, and compiled pattern reuse.', 'Lead', 30, true, 1),
    ('collection-performance-java', 'Collection Performance in Java', 'Pick collections from the operation mix, presize large structures, and keep boxing out of measured hot paths.', 'Lead', 32, true, 1),
    ('io-and-network-performance', 'IO and Network Performance', 'Cut system call overhead with buffering, choose channels for connection scale, and weigh batching and compression costs.', 'Lead', 34, true, 1),
    ('async-io-and-reactor-performance', 'Async IO and Reactor Performance', 'Learn where reactive pipelines pay for themselves in IO concurrency and where they add latency, limits, and complexity.', 'Lead', 36, true, 1),
    ('performance-regression-prevention', 'Performance Regression Prevention', 'Prevent slow regressions with performance budgets, careful microbenchmark use, canaries, and alerts on SLO drift.', 'Mid', 26, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('java-performance-methodology', 1, 'Define the metric before optimizing', $body$Performance work starts with a decision, not a tool. Name the user-visible metric, for example p99 checkout latency or jobs completed per hour, and the target value. Without a defined metric, any change can be argued as an improvement. Record the workload that produced the number: request mix, data size, concurrency, and hardware, because a result without context is not evidence. The main pitfall is optimizing a proxy such as CPU utilization while the user-visible metric stays flat. Rule of thumb: if you cannot state the metric, the baseline, and the target in one sentence, you are not ready to tune anything.$body$, $code$# State the metric, baseline, and target before touching any flag.
Metric:   p99 order submit latency (ms)
Baseline: 240 ms at 300 req/s, 4 vCPU, 30 min steady load
Target:   150 ms with no error-budget regression
# Record context with every number.
Workload: 8 KB payloads, 200 ms dependency call, 20% writes$code$),
    ('java-performance-methodology', 2, 'Change one variable per experiment', $body$A performance experiment needs a baseline and a single change. If you adjust heap size, thread count, and batch size together, you cannot attribute the result to any of them. Take repeated measurements: JVM behavior varies between runs because of compilation activity, garbage collection timing, and machine noise, so one run is a coin flip. Keep a written record of each experiment: hypothesis, change, metric, result, and decision. Revert changes that do not help, because unmeasured configuration accumulates. The pitfall is drawing conclusions from a single run on a busy developer laptop. Rule of thumb: several runs, look at the spread, and prefer changes that move both the median and the tail.$body$, $code$# One experiment, one variable.
Hypothesis: pool wait drives p99 submit latency
Change:     maximumPoolSize 10 -> 24
Measure:    p99 over five 30-minute runs
Baseline:   240 ms p99
Result:     196 ms p99 (spread 190-205)
Decision:   keep, re-measure next week$code$),
    ('java-performance-methodology', 3, 'Avoid premature optimization folklore', $body$Folklore substitutes for measurement: shorter methods are always faster, streams are always slow, interning always helps. Modern just-in-time compilers inline aggressively and remove many abstractions, so intuition about source shape often predicts nothing about machine behavior. Acting on folklore costs effort and makes code harder to read for no measured benefit. Optimize where profiles show cost and leave clear code everywhere else. When a change does help, keep the measurement that justifies it so a future reader does not revert it during a cleanup. Rule of thumb: write the clear version first, measure the whole system, and only then trade readability for speed where the metric demands it.$body$, $code$record OrderKey(String tenant, long orderId) {}

// Keep the readable version until a profile shows this site
// costing real time on a sustained workload.
OrderKey key = new OrderKey(tenant, orderId);

// Written after evidence, with the capture kept next to it:
// a small primitive key removed 12% of allocation rate.$code$),
    ('profiling-cpu-hotspots', 1, 'Sampling profilers and flame graphs', $body$A sampling profiler interrupts running threads at a fixed rate and records stack traces, so sample counts estimate where time is spent. Flame graphs aggregate those stacks: width is proportional to samples, so wide frames dominate the picture. Use CPU sampling when you care about compute and wall-clock sampling when threads block. Sampling is statistical, so a narrow frame in a short capture may be noise. The main pitfall is profiling a workload that does not match production, where synthetic data hides the real hot path. Rule of thumb: capture a representative steady-state window of at least a few minutes, and treat anything under roughly one percent of samples as unproven.$body$, $code$# 30-second wall-clock profile of a running JVM
asprof -d 30 -e wall -f flame.html <pid>
# Same window as a JFR recording for offline analysis
jcmd <pid> JFR.start duration=60s filename=hot.jfr settings=profile
# Read the widest frames first, top-down.$code$),
    ('profiling-cpu-hotspots', 2, 'Separating CPU from lock time', $body$High CPU and high latency look similar from the outside but have different fixes. When the process burns CPU, the profile shows wide frames in application or library code. When threads wait on monitors, sockets, or pools, a CPU profile looks oddly empty and wall-clock or lock profiling shows the real cost. Thread states help: many threads in BLOCKED or WAITING with low CPU points to contention or a saturated dependency, not a hot method. The pitfall is attacking a method that appears hot only because it waits inside. Rule of thumb: compare CPU utilization with profile totals first; when CPU is low but latency is high, profile waiting rather than computation.$body$, $code$# CPU-bound? the CPU profile will show wide application frames.
# Low CPU with high latency points at waits, not computation.
jcmd <pid> Thread.print | grep -E "BLOCKED|WAITING" | head
jcmd <pid> JFR.start duration=60s filename=waits.jfr settings=profile
# Contention and parking events show where threads stalled.$code$),
    ('profiling-cpu-hotspots', 3, 'Reading evidence without overclaiming', $body$A profile is evidence, not a verdict. A hot frame may be a symptom: a logging library appearing high often reflects excessive log volume rather than slow logging code. Distinguish self time from total time, because a frame present in many stacks but thin at the top may simply call expensive children. Confirm hypotheses by changing one thing and re-profiling; if the frame does not shrink, the theory was wrong. The pitfall is rewriting the hottest method without connecting it to the user-visible metric. Rule of thumb: every profile-driven change should name the frame it targets, the metric it should move, and the re-measurement that confirms it.$body$, $code$# Sample profile: 18% in handleRequest, 11% in logLine, 9% in hash
# 1. Is the frame self time or just a parent of expensive children?
# 2. Which metric did this cost? p99 rose after a cache was removed.
# 3. Change one thing, re-profile, and keep both captures.
# A hot frame that survives every change is a real candidate.$code$),
    ('memory-profiling-in-practice', 1, 'Heap dumps and dominator reasoning', $body$A heap dump captures object graphs at one moment, which makes retention visible. Tools summarize by retained size, and dominator trees expose the small set of holders keeping whole graphs alive, because one object dominates another when every path from a root passes through it. Large shallow sizes are usually arrays and buffers; large retained sizes are collections, caches, and session maps. Take two dumps separated in time under load, because growth between them separates a leak from steady state; one dump is not a trend. Rule of thumb: dump near the high-water mark, compare two points, and trace the shortest path from a garbage collection root to the suspect.$body$, $code$# Two dumps separated by time, each after a forced full collection.
jcmd <pid> GC.run
jcmd <pid> GC.heap_dump first.hprof
jcmd <pid> GC.run
jcmd <pid> GC.heap_dump second.hprof
# Compare retained sizes of the largest dominators between dumps.$code$),
    ('memory-profiling-in-practice', 2, 'Allocation profiling for churn', $body$Allocation profiling answers a different question than heap dumps: not what is retained, but what is created. A high allocation rate raises garbage collection frequency and costs throughput even when the live set is small. Capture allocations by class and by site, then look for short-lived temporaries on hot paths, such as per-request formatters, boxed numbers, or intermediate collections. Escape analysis removes some allocations, so verify with a profile rather than assuming. The pitfall is blaming the collector for pressure created by application code. Rule of thumb: when allocation rate scales with traffic but the live set does not, fix allocation sites before touching garbage collection flags.$body$, $code$# Allocation sampling, then read by class and by site.
jcmd <pid> JFR.start name=alloc settings=profile duration=120s filename=alloc.jfr
jfr view allocation-by-class alloc.jfr
jfr view allocation-by-site alloc.jfr
# Watch for per-request temporaries on hot paths.$code$),
    ('memory-profiling-in-practice', 3, 'Distinguishing leaks from high churn', $body$A leak grows retained size across full collections; high churn keeps retained size flat while allocating heavily, and the two need opposite responses. To confirm a suspected leak, force a full collection before each dump: if the old generation still grows, something holds references. Common holders are static maps without eviction, listeners never removed, thread-local values on pooled threads, and caches with no size bound. High churn instead shows a sawtooth heap with frequent young collections and low survivor occupancy. The pitfall is disabling the collector for an application retention bug. Rule of thumb: track live-set size after full collections over hours; a monotonic climb is a leak, a flat line with allocation pressure is a design problem.$body$, $code$// Retained size that grows after full collections points here.
static final Map<String, Session> SESSIONS = new ConcurrentHashMap<>();

void touch(Session session) {
    SESSIONS.put(session.id(), session);   // never removed
}
// Fix: bounded cache or explicit eviction, not a GC flag.$code$),
    ('gc-tuning-in-practice', 1, 'Start with defaults and read logs', $body$Modern collectors are adaptive, so the first job is observation, not flag editing. Enable unified logging and read pause frequency, pause duration, and the heap occupancy curve after each collection. Size the heap explicitly: in containers, set a maximum you can explain, because the JVM sees container limits but not the memory your co-tenants need. Also watch allocation rate, because a collector is judged against how fast the application creates garbage. The pitfall is copying flags from a post written for a different heap size, collector, and traffic pattern. Rule of thumb: run defaults with logging for a week, then change at most one thing that the logs justify.$body$, $code$# Observe first: unified logging with rotation.
java -Xlog:gc*:file=gc.log:time,uptime,level,tags:filecount=5,filesize=20M \
     -Xmx3g -jar service.jar
# Explain the heap size you chose, including container headroom.
java -XX:MaxRAMPercentage=70 -jar service.jar$code$),
    ('gc-tuning-in-practice', 2, 'Choose pause or throughput goals', $body$Garbage collection tuning is a trade: shorter pauses usually cost throughput and headroom, while higher throughput accepts longer stops. G1 targets a soft pause goal, Parallel favors throughput, and ZGC and Shenandoah aim at pauses in the low milliseconds at some CPU cost. Decide what the service actually needs: interactive request paths care about the pause contribution to p99, batch jobs care about total CPU. The pitfall is setting a very aggressive pause goal on a modest heap, which makes G1 collect more often and can lower throughput. Rule of thumb: state the goal in milliseconds and percent, then verify it with logs instead of assuming the flag was honored.$body$, $code$# Pause-sensitive request path
java -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -Xmx8g -jar service.jar
# Throughput-first batch job
java -XX:+UseParallelGC -Xmx8g -jar batch.jar
# Low-pause collector when latency dominates and CPU headroom exists
java -XX:+UseZGC -Xmx8g -jar service.jar$code$),
    ('gc-tuning-in-practice', 3, 'When tuning is the wrong fix', $body$The most common tuning request follows an allocation or retention problem. If the heap fills with live data faster than the collector can reclaim, no flag fixes it: reduce retention, cap caches, or add memory. If pauses are acceptable but the tail is bad, the collector is not the bottleneck. Check the environment too, because container limits, swap, and co-tenant CPU pressure distort every measurement. Constant full collections with a live set near the maximum are a data-lifetime signal, not a collector signal. Rule of thumb: tune only when live-set size is stable, allocation rate is understood, and logs show the collector itself is the delay rather than a symptom.$body$, $code$# Facts the collector cannot change.
jcmd <pid> GC.heap_info
jcmd <pid> GC.class_histogram | head -20
# Live set near Xmx with constant full collections:
# reduce retention, cap caches, or add memory before tuning flags.$code$),
    ('jit-compilation-and-warmup', 1, 'From interpreter to C2 tiers', $body$HotSpot starts by interpreting bytecode, counts method and loop invocations, and compiles hot code through tiered levels toward C2, which applies aggressive inlining and speculative optimization. Early requests therefore run slow, and throughput improves over minutes as code reaches peak compilation. Profiling data drives those decisions, so a method that stops being called can be reverted. The practical consequence is that a fresh process is not representative of a long-running one. The pitfall is capacity planning from the first minute of a run. Rule of thumb: treat warmup as a measurable phase, and give production replicas traffic and time before judging their latency.$body$, $code$# Watch tiers settle: compiled level appears in the third column.
java -XX:+PrintCompilation -jar service.jar 2>&1 | head -20
java -Xlog:jit+compilation=info -jar service.jar
# Steady state arrives after minutes, not after the first request.$code$),
    ('jit-compilation-and-warmup', 2, 'Deoptimization and benchmark lies', $body$Speculative compilation depends on assumptions, such as a call site seeing only one implementation. When an assumption fails, the JVM deoptimizes and falls back to the interpreter or a less optimized version until recompilation, which can show as a spike when a rare type first appears. In production this is normal. In benchmarks it is fatal: a run that never warms up, or lets the compiler constant-fold the work away, reports meaningless numbers. Use established measurement tools that handle warmup, dead-code elimination, and iteration counts instead of a hand-rolled timer loop. Rule of thumb: log deoptimization events when diagnosing post-deploy spikes, and never trust a homemade benchmark for JIT-compiled code.$body$, $code$# Deoptimization events often explain a post-deploy latency spike.
java -Xlog:deoptimization=info -jar service.jar
# In benchmarks, check that warmup and dead-code elimination
# are handled before trusting any number.$code$),
    ('jit-compilation-and-warmup', 3, 'Warmup in containers and serverless', $body$Short-lived processes never reach C2, so they pay interpreter and lower-tier costs for their whole life. Serverless functions and aggressively autoscaled replicas amplify this, showing higher latency exactly when load is highest. Mitigations exist but each has a price: class data sharing archives reduce class loading and startup, limiting compilation tiers saves CPU at the expense of peak throughput, and keeping replicas warm costs idle capacity. Measure what the platform actually runs, because warmup curves differ between a long-lived pod and a per-request sandbox. Rule of thumb: optimize steady state for long-lived replicas, optimize startup for short-lived ones, and never assume one configuration fits both.$body$, $code$# Faster startup for short-lived replicas
java -XX:ArchiveClassesAtExit=app.jsa -jar service.jar
java -XX:SharedArchiveFile=app.jsa -jar service.jar
# Trade peak throughput for startup CPU if replicas are very short-lived
java -XX:SharedArchiveFile=app.jsa -XX:TieredStopAtLevel=1 -jar service.jar$code$),
    ('throughput-vs-latency', 1, 'Two metrics, two different games', $body$Throughput counts completed work per unit time; latency describes how long one unit takes. A service can maximize one while degrading the other, because queueing batches raises items per second while each item waits longer. Report latency as percentiles, not averages, since averages hide the queueing tail that users feel. Under saturation, queueing theory links the two: concurrency equals arrival rate multiplied by residence time, so knowing any two gives the third. The pitfall is optimizing throughput and discovering that interactive users time out during peaks. Rule of thumb: name the primary metric explicitly, then track the other as a guardrail with an agreed limit.$body$, $code$# Report the distribution, not one number.
p50: 12 ms    p95: 40 ms    p99: 180 ms    max: 2100 ms
# A mean of 25 ms hides the 180 ms tail users actually feel.
# Concurrency ~= arrival rate x residence time at saturation.
# Choose the primary metric, then guard the other.$code$),
    ('throughput-vs-latency', 2, 'Batching trades throughput for p99', $body$Batching amortizes fixed costs, such as a database round trip or a syscall, across many items, so throughput rises. It also adds waiting: the first item in a batch waits for the batch to fill or for a timer to expire, and that wait lands directly in p99. The tension is unavoidable; the engineering question is where the wait is acceptable. Batch sizes and flush intervals should be derived from the latency budget rather than chosen for convenience. The pitfall is measuring average batch completion time and missing the client-visible tail. Rule of thumb: size batches from the p99 budget, keep flush intervals configurable, and monitor both batch size and wait time.$body$, $code$// Batch for throughput, but bound the wait for the tail.
int maxBatch = 500;
long maxWaitMillis = 20;   // derived from the p99 budget
// Flush when either bound is reached and monitor both:
// batch size observed and time an item waited before flush.$code$),
    ('throughput-vs-latency', 3, 'Tail latency amplification', $body$A request that fans out to many services inherits the slowest of them: when one backend is slow for one percent of calls, a fan-out of a hundred makes a slow path likely for most requests. This amplification means per-dependency tail targets must be far tighter than the overall objective. Retries worsen it by multiplying load on an already slow dependency, and hedged requests spend capacity to hide latency. The pitfall is assigning every dependency the same p99 target and assuming the composite will meet it. Rule of thumb: budget tails per hop, cap retries with deadlines, and treat any dependency whose slow fraction is unknown as a risk.$body$, $code$// Fan-out inherits the slowest call: budget tails per hop.
Instant deadline = Instant.now().plusMillis(200);
for (Call call : calls) {
    call.timeout(remaining(deadline));  // fail inside the budget
}
// Retries multiply load; cap them and keep total deadline.$code$),
    ('load-test-driven-tuning', 1, 'Model real traffic shape', $body$A load test is a model of production, and a wrong model produces confident wrong answers. Start from observed traffic: endpoint mix and payload sizes, read-to-write ratio, think time, and daily peaks. Capture a real session shape instead of hammering one endpoint, because the bottleneck under a mixed workload is often different from the one under a single hot route. Include data that grows the way production data grows, since scan and index behavior depends on table size. The pitfall is testing against empty databases with uniform identifiers. Rule of thumb: derive the profile from production telemetry, and revise the model whenever the evidence says production changed.$body$, $code$// Traffic shape from production, not from an empty database.
export const options = {
  scenarios: {
    steady: {
      executor: 'constant-arrival-rate',
      rate: 300, timeUnit: '1s', duration: '30m',
      preAllocatedVUs: 200, maxVUs: 600,
    },
  },
};$code$),
    ('load-test-driven-tuning', 2, 'Closed and open workload models', $body$A closed model keeps a fixed number of virtual users, each waiting for a response before sending the next request, so a slow system automatically reduces pressure. That is useful for capacity discovery but hides overload behavior. An open model sends requests at a fixed arrival rate regardless of response time, like real users and upstream callers, and it exposes queue collapse when capacity is exceeded. Most realistic tests include both phases: open-loop arrival for steady state, then a step up to find the knee. The pitfall is reporting p99 from a closed test where the generator throttled itself. Rule of thumb: use open-loop for latency claims and closed-loop for saturation probing.$body$, $code$// Closed loop: each virtual user waits for a response.
export const options = {
  scenarios: {
    probe: { executor: 'constant-vus', vus: 100, duration: '10m' },
  },
};
// Use it to find saturation; use open-loop to claim latency.$code$),
    ('load-test-driven-tuning', 3, 'Steady-state analysis and ramps', $body$The interesting number is not the peak but the settled state: throughput, latency percentiles, error rate, and resource use after warmup and after queues reach equilibrium. Ramp gradually so you can see where latency stops being flat; the knee is more useful than the collapse point. Run long enough for compilation, cache warmup, and a few garbage collection cycles to be represented, then repeat the run to confirm stability. The pitfall is treating the first minute as steady state. Rule of thumb: report a time window at steady state rather than one summary of the whole run, and keep the raw data.$body$, $code$# Steady-state window, minutes 20 to 40 after warmup
throughput 1.9k rps | p50 24 ms | p99 210 ms | errors 0.02%
# Knee: latency leaves the flat region near 2.1k rps
# Report the window, not a single summary of the whole run.$code$),
    ('database-performance-tuning', 1, 'Slow query triage by evidence', $body$Start from the slow-query log or statement statistics, not intuition about which statement is expensive. Triage by total time contribution: a 5 ms query called a thousand times per request often costs more than one slow report. Reproduce the exact statement with representative parameter values, because plans differ between a selective identifier and a wide range. Read the plan for scan type, estimated versus actual rows, and sort or temporary usage. The pitfall is tuning a query that is fast in isolation but serialized behind a lock in production. Rule of thumb: rank by total time and call frequency, then confirm the plan before touching SQL or indexes.$body$, $code$EXPLAIN (ANALYZE, BUFFERS)
SELECT id, total FROM orders
WHERE tenant_id = $1 AND created_at >= $2
ORDER BY created_at DESC
LIMIT 50;
-- Read scan type, estimated vs actual rows, and buffer hits.$code$),
    ('database-performance-tuning', 2, 'Verifying index usage with plans', $body$Adding an index is a hypothesis about access paths: it should turn a scan into a lookup for the queries you care about. Verify with the plan, not with the presence of the index in the catalog. Composite indexes serve equality and range predicates in column order, so an index on tenant and created_at supports both the filter and the ordering; separate single-column indexes often do not. Every index adds write cost and storage, so remove ones no query uses. The pitfall is trusting an index the planner ignores because of type mismatches or stale statistics. Rule of thumb: pair each new index with the plan it changes and the write cost it adds.$body$, $code$CREATE INDEX CONCURRENTLY idx_orders_tenant_created
    ON orders (tenant_id, created_at DESC);
-- Verify the target query uses it, then re-check write cost.
SELECT indexrelname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
WHERE relname = 'orders';$code$),
    ('database-performance-tuning', 3, 'Pool size versus database capacity', $body$Application pools multiply: twenty replicas with a pool of thirty can open six hundred connections, and a database that handles sixty concurrent workers spends its time switching contexts instead of executing. Pool size should reflect database capacity divided by replica count, not the number that made a single-service test fast. Writes and long transactions hold connections longer, so read and write paths often deserve separate budgets. The pitfall is raising pool size to fix waiting that a missing index created. Rule of thumb: size pools from measured database concurrency and lock behavior, keep the total predictable, and alert on connection wait time.$body$, $code$# Capacity budget: useful database concurrency ~ 60
# Replicas: 12, so per-replica pool ~ 5, not 30
# Read and write paths can have separate budgets.
# Check: connection wait time stays near zero at peak.
# Alert on pool wait, not just pool utilization.$code$),
    ('jdbc-and-pool-tuning', 1, 'Sizing pools with a queueing view', $body$A connection pool is a queue with servers, so queueing intuition applies: busy connections equal arrival rate multiplied by average hold time. If a request holds a connection for 15 ms and the service handles 1000 requests per second, roughly 15 connections are busy on average, and headroom covers variance and bursts. Pools far smaller than that queue requests; pools far larger exhaust the database. Measure hold time per query class and pool wait time before changing size. The pitfall is assuming more connections mean more throughput when the bottleneck is downstream. Rule of thumb: size from hold time and arrival rate, then confirm with observed wait time.$body$, $code$// Pool size from hold time and arrival rate.
// 1000 req/s x 15 ms hold time ~= 15 connections busy on average.
HikariConfig config = new HikariConfig();
config.setMaximumPoolSize(20);   // plus variance headroom
config.setMinimumIdle(5);$code$),
    ('jdbc-and-pool-tuning', 2, 'Timeout posture end to end', $body$Every layer has a timeout, and the shortest meaningful one should win. A connection acquisition timeout that waits forever hides an exhausted pool, and a statement timeout longer than the client deadline produces work nobody will read. Set acquisition, statement, query, and socket timeouts so that a request fails inside the caller budget and releases its connection. Then make failure behavior explicit: bounded retries for transient errors, none for validation failures. The pitfall is a long pool wait followed by a fast query, which turns a slow dependency into a stalled service. Rule of thumb: timeouts decrease toward the caller, and pool wait stays strictly inside the request budget.$body$, $code$HikariConfig config = new HikariConfig();
config.setConnectionTimeout(250);    // fail inside request budget
config.setValidationTimeout(1000);
config.setMaxLifetime(1_800_000);    // below any server idle cut
config.setKeepaliveTime(300_000);
// Statement and socket timeouts must be shorter than the client deadline.$code$),
    ('jdbc-and-pool-tuning', 3, 'Prepared statements and reuse', $body$Prepared statements save parsing and planning on the database side, but only when the driver reuses them. Most drivers cache prepared statements per connection, and a cache that is too small re-prepares under load while one that is too large wastes server memory. Measure before tuning: parse cost matters for high-frequency queries with simple plans and matters little when execution time dominates. The pitfall is enabling a large cache and blaming the database for memory growth. Rule of thumb: reuse prepared statements for hot repeated queries, keep the cache modest, and verify with execution statistics that reuse actually happens.$body$, $code$// Reuse for hot, repeated queries; keep the cache modest.
config.addDataSourceProperty("prepareThreshold", "5");
config.addDataSourceProperty("preparedStatementCacheQueries", "128");
// Larger caches cost server memory per connection.
// Verify reuse with execution statistics before increasing it.$code$),
    ('serialization-performance', 1, 'Understand the all-in cost of JSON', $body$Serialization cost is rarely one thing: field access, string handling for names and numbers, allocation of intermediate trees, and UTF-8 encoding add up per request. Measure the full path at realistic payload sizes for your contract, because cost grows with nesting depth and collection length. A small payload serialized a million times costs more than a large one serialized rarely, so weigh call frequency, not only message size. The pitfall is optimizing the library before checking whether serialization is a visible share of the request. Rule of thumb: profile first, prefer flat objects over deeply nested maps on hot paths, and treat payload size as a reviewed API property.$body$, $code$// Serialization cost is the whole path: access, names, encoding.
byte[] body = objectMapper.writeValueAsBytes(order);
// Payload shape drives cost: prefer flat records over nested maps
// and review size growth as an API property.
// Measure at realistic sizes before changing libraries.$code$),
    ('serialization-performance', 2, 'Streaming models versus tree models', $body$Tree models build a complete object graph before you can use it; streaming models emit events as bytes are parsed. Streaming wins when payloads are large, only part of the document is needed, or memory must stay bounded, as in export and bulk-ingest endpoints. Tree models win for small, irregular documents where random access and clarity matter. Mixing is fine: stream the array elements and map each element to a small tree. The pitfall is holding a whole parsed tree while believing memory is bounded by the response size. Rule of thumb: choose streaming when payload size follows data volume, and tree models when it follows a fixed contract.$body$, $code$// Streaming keeps memory bounded for large documents.
try (JsonParser parser = factory.createParser(input)) {
    while (parser.nextToken() != null) {
        if (parser.currentToken() == JsonToken.START_OBJECT) {
            sink.accept(mapper.readValue(parser, Item.class));
        }
    }
}$code$),
    ('serialization-performance', 3, 'Avoid double serialization', $body$A common hidden cost is serializing the same data more than once: converting an object to a string for a cache, then parsing and re-serializing it for the response. Each hop pays encode, allocation, and decode. Pass bytes or already-encoded bodies through when the contract allows, and cache the serialized form rather than the object when the cached item is served verbatim. The same applies to logging, where formatting a large object for a line that is usually filtered still costs. The pitfall is measuring one layer and missing repeated conversion above it. Rule of thumb: trace a payload end to end, count conversions, and delete one.$body$, $code$// One payload, one conversion: cache the encoded form.
String json = cache.getIfPresent(key);
if (json == null) {
    json = mapper.writeValueAsString(view);
    cache.put(key, json);
}
return ResponseEntity.ok().contentType(MediaType.APPLICATION_JSON).body(json);$code$),
    ('string-performance-java', 1, 'Interning deduplication and identity', $body$Strings dominate many heaps because every parsed field, key, and log fragment is one. String literals share storage through the string table, and manual intern can reduce duplication for repeated identifiers, but it adds lookup cost and retains entries for the process lifetime. G1 string deduplication instead detects equal backing arrays and points them at one copy, lowering footprint without changing identity semantics. Both help only when duplication is real, so verify with a histogram before enabling anything. The pitfall is interning attacker-controlled values, which grows the table without bound. Rule of thumb: measure duplicate content first, deduplicate repeated structured values, and never intern unbounded input.$body$, $code$# Look for one dominant java.lang.String row.
jcmd <pid> GC.class_histogram | head -20
# Or enable deduplication and watch what it reclaims.
java -XX:+UseG1GC -XX:+UseStringDeduplication -Xlog:stringdedup=info -jar app.jar
# Deduplicate repeated structured values; never intern unbounded input.$code$),
    ('string-performance-java', 2, 'Concatenation and formatting cost', $body$String concatenation in a loop can be quadratic when each step copies the accumulated text; the compiler rewrites simple concatenation to a string builder, but not across loop iterations. When the result grows, hold an explicit StringBuilder and size it from an estimate. Formatting is a different cost: each call parses the pattern and allocates, so hot log lines and numeric rendering can benefit from cheaper alternatives such as appending known parts. The pitfall is optimizing string work that never appears in a profile because the loop runs rarely. Rule of thumb: measure the string path as part of the whole request, and only then trade readability for speed.$body$, $code$StringBuilder out = new StringBuilder(input.length() + 32);
for (Row row : rows) {
    out.append(row.id()).append('=').append(row.value()).append(';');
}
return out.toString();
// Sizing the builder removes repeated growth in large loops.$code$),
    ('string-performance-java', 3, 'Regex compilation and reuse', $body$Compiling a pattern is expensive relative to matching small inputs, and Java caches nothing for you unless the pattern is a constant expression. Move patterns to static final fields or a small bounded cache keyed by pattern text, and never compile inside a loop or per request. Watch for catastrophic backtracking: patterns with nested quantifiers can take exponential time on crafted input, which is a denial-of-service risk rather than a slowdown. Prefer possessive or atomic constructs where appropriate, validate input length before matching, and test with adversarial strings. The pitfall is recompiling identical patterns on every call. Rule of thumb: compile once, cache with a bound, and treat untrusted input as hostile.$body$, $code$private static final Pattern ORDER_ID = Pattern.compile("[a-z]{2}\\d{8}");

boolean valid = ORDER_ID.matcher(candidate).matches();
// Compile once; never Pattern.compile inside a request path.
// Anchor and bound input length before matching untrusted text.$code$),
    ('collection-performance-java', 1, 'Choosing collections by operation mix', $body$Collection choice follows the operations, not habit. ArrayList costs constant time for indexing and appends but linear time for contains; HashSet gives constant-time membership at the price of hashing and memory; TreeMap adds ordering with logarithmic operations. Removing from the middle of an ArrayList is linear, and LinkedList is rarely the right answer on modern hardware because pointer chasing defeats cache locality. Decide iteration order requirements up front, because they constrain the implementation. The pitfall is choosing a type for one operation while ignoring the dominant one. Rule of thumb: list the hot-path operations and their frequency, then pick the structure that makes the most frequent ones cheap.$body$, $code$// Operation mix first: indexing, membership, or ordering?
List<Order> recent = new ArrayList<>();     // index and append
Set<String> seen = new HashSet<>();         // membership
Map<String, Order> byId = new HashMap<>();  // lookup by key
// Removing from the middle of an ArrayList is O(n); that is the cost.$code$),
    ('collection-performance-java', 2, 'Presize before bulk insert', $body$HashMap and ArrayList grow by reallocating and rehashing, so building a large collection from default capacity pays repeated copying. When the final size is known or can be estimated, size the structure once; a map expected to hold a thousand entries at the default load factor wants an initial capacity near 1400 to avoid a resize. Resizing is not catastrophic and often invisible, so this matters mostly for large structures built frequently. The pitfall is micro-optimizing constructor arguments on tiny collections while major costs sit elsewhere. Rule of thumb: presize when the collection is large or built per request at high rate, and confirm the allocation shows up in profiles.$body$, $code$int expected = 10_000;
List<Row> rows = new ArrayList<>(expected);
Map<String, Row> index = new HashMap<>((int) (expected / 0.75f) + 1);
// One allocation instead of repeated resize and rehash.
// Presize large structures built per request on hot paths.$code$),
    ('collection-performance-java', 3, 'Boxing and primitive stream caution', $body$Generics require reference types, so integers in collections are boxed, adding allocation and indirection. Primitive collections or plain arrays remove that cost where it is measured, and primitive streams can avoid boxing if you stay in IntStream, LongStream, or DoubleStream rather than mixing boxed elements into the pipeline. Autoboxing also hides identity surprises, because cached small values make reference comparison accidentally pass in tests and fail later. The pitfall is converting a clear pipeline to manual loops for savings no profile shows. Rule of thumb: check the allocation profile for boxed types on hot paths, and only then leave the idiomatic form.$body$, $code$// Stay primitive to avoid boxing in aggregation.
long total = orders.stream().mapToLong(Order::totalCents).sum();
Map<String, Integer> counts = new HashMap<>();  // Integer boxes here
// Autoboxing surprises: cached small values break == comparisons.
// Check the allocation profile before rewriting idiomatic code.$code$),
    ('io-and-network-performance', 1, 'Buffering and system call cost', $body$Unbuffered reads and writes pay a system call per small operation, and the kernel round trip can dominate the payload. Buffered streams batch many small logical writes into fewer system calls, which is why wrapping is the default advice on hot paths. Buffer size follows the access pattern: large sequential copies benefit from bigger buffers, interactive sockets from smaller ones, and the buffering layer must never change the semantic contract. The pitfall is flushing after every record, silently converting a buffered writer into many syscalls. Rule of thumb: buffer anything read or written in a loop, count flush and syscall activity when unsure, and never flush per record.$body$, $code$try (var reader = new BufferedReader(
        new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8),
        32 * 1024)) {
    String line;
    while ((line = reader.readLine()) != null) {
        handle(line);
    }
}$code$),
    ('io-and-network-performance', 2, 'Channels and readiness models', $body$NIO channels separate byte movement from readiness notification: you ask a selector which channels can progress and then transfer buffers yourself. That scales connection count with a few threads rather than one per connection, which matters for tens of thousands of mostly idle clients. It also moves complexity into your code, including partial reads, buffer management, and fairness between channels. Blocking IO stays simpler and often faster per operation for modest connection counts. The pitfall is adopting non-blocking channels for a few hundred connections and paying complexity for no measured gain. Rule of thumb: choose channels for connection scale or long-poll patterns, and keep blocking IO where simplicity wins.$body$, $code$Selector selector = Selector.open();
channel.configureBlocking(false);
channel.register(selector, SelectionKey.OP_READ);
// One thread can track many idle connections this way.
// It also means you handle partial reads yourself.$code$),
    ('io-and-network-performance', 3, 'Batching and compression trade-offs', $body$Compression trades CPU for bytes on the wire, so it wins when bandwidth or transfer time is the bottleneck and loses when CPU is saturated or payloads are small and incompressible. Evaluate levels rather than enabling the strongest setting, since maximum compression often costs several times the CPU for a modest size reduction. Batching many small messages into one payload cuts per-message overhead but adds latency and complicates partial failure handling. Both decisions interact with the serialization format already chosen. The pitfall is compressing internal high-throughput traffic where bandwidth was never the limit. Rule of thumb: measure bytes and CPU per request, compress above a size threshold, and treat batch size as a latency decision.$body$, $code$// Compress only where bytes on the wire are the bottleneck.
if (payload.length > 1024) {
    try (var gzip = new GZIPOutputStream(response.getOutputStream())) {
        gzip.write(payload);
    }
}
// Choose the level deliberately; maximum costs CPU for small gains.$code$),
    ('async-io-and-reactor-performance', 1, 'Reactive payoffs and prices', $body$Reactive stacks pay off when a workload is dominated by waiting on many concurrent IO operations: one event-loop thread can orchestrate thousands of in-flight calls without a thread per request. The price is a different execution model, where operators chain lazily, stack traces fragment, and operators that look cheap allocate per element. Measure before adopting; a service that is CPU-bound or calls a small set of fast dependencies often performs as well with blocking code and simpler operations. The pitfall is rewriting a working blocking service without a measured concurrency problem. Rule of thumb: adopt reactive when measured IO concurrency, not fashion, drives thread exhaustion.$body$, $code$// Reactive pays off on many concurrent IO waits.
Flux<Quote> quotes = Flux.fromIterable(symbols)
    .flatMap(symbol -> client.getQuote(symbol), 64);  // bounded concurrency
// For CPU-heavy work, blocking code is often simpler and as fast.
// Measure thread exhaustion before rewriting a blocking service.$code$),
    ('async-io-and-reactor-performance', 2, 'Keep CPU work off event loop', $body$An event loop must never block: any CPU-heavy or blocking call on it stalls every stream it serves. Move blocking calls, such as legacy JDBC or synchronous clients, off the loop with a bounded scheduler sized from available cores, and keep CPU-bound transformations short or delegate them. Watch for accidental blocking inside operators, such as synchronous HTTP clients in a flatMap or locks that wait on IO. Blocking detectors can flag violations during tests. The pitfall is assuming a reactive API implies non-blocking internals. Rule of thumb: every operator on the hot path must be provably non-blocking and short, or explicitly scheduled elsewhere.$body$, $code$return Mono.fromCallable(() -> legacyJdbcQuery(id))
    .subscribeOn(Schedulers.boundedElastic());
// Blocking call, explicitly moved off the event loop.
// Every hot-path operator must be non-blocking and short.
// Size the scheduler from available cores, not from request volume.$code$),
    ('async-io-and-reactor-performance', 3, 'Backpressure and blocking traps', $body$Backpressure is the ability to slow producers when consumers lag; without it, fast sources fill memory and fail under load. Reactive libraries express it through request accounting, but it only helps when every stage respects demand and unbounded operators are avoided. Buffering and windowing can hide the symptom temporarily and turn a latency problem into an out-of-memory problem. Decide failure policy per stage, with explicit limits for timeouts, retries, and fallbacks. The pitfall is treating backpressure as an implementation detail until an incident teaches otherwise. Rule of thumb: never use unbounded queues on a request path, set limits deliberately, and load test the saturation behavior of the pipeline.$body$, $code$Flux<Event> stream = source.flatMap(event -> handle(event), 32);
// Bounded inner concurrency keeps producers honest.
// Unbounded merge() hides missing backpressure until memory runs out.
// Set explicit limits for timeouts, retries, and buffering.
// Load test the saturation behavior, not just the happy path.$code$),
    ('performance-regression-prevention', 1, 'Performance budgets in delivery', $body$A performance budget turns intent into a checkable number: maximum p99 latency, minimum throughput, allocation or payload size limits, and startup time for cold replicas. Budgets work when they are owned and visible, attached to a service, reviewed in pull requests, and reported beside functional signals. Compare against the main-branch baseline with a tolerance for noise, so ordinary variance does not block delivery. Update budgets deliberately when requirements change, and record why. The pitfall is a dashboard nobody consults until an incident. Rule of thumb: every budget needs an owner, a measurement, and a consequence when it is breached.$body$, $code$# Budget attached to the service, reviewed before merge.
service: orders-api
p99_ms: 150
min_throughput_rps: 500
startup_ms: 4000
tolerance: 5%   # allowed run-to-run noise$code$),
    ('performance-regression-prevention', 2, 'Microbenchmarks and production canaries', $body$Microbenchmarks answer narrow questions about a method or data structure under controlled conditions; they are the wrong tool for system behavior, and just-in-time compilation makes them easy to get wrong. Production canaries measure what matters: real traffic shape, caches, and dependency latency, at the cost of a staged rollout and a rollback path. The two complement each other, because a microbenchmark can explain why a canary showed a regression. The pitfall is approving a change because a hand-written benchmark improved, then finding the deployed service slower. Rule of thumb: use microbenchmarks for mechanism and canaries or staged load tests for outcomes.$body$, $code$# Canary: 5% of live traffic for 30 minutes.
# Compare with the stable group on p99, error rate, CPU per request.
# Roll back automatically when a guardrail degrades past tolerance.
# Keep microbenchmarks for mechanism, not for release decisions.
# Staged load tests cover what canaries cannot reproduce.$code$),
    ('performance-regression-prevention', 3, 'Alerting on SLO drift', $body$Gradual regressions do not trigger error alerts, so guardrails must watch trends, not only thresholds. Alert on SLO burn signals, such as the rate at which the error budget is consumed, and on slow drift in latency percentiles and resource saturation compared with the same window a week earlier. Keep alerts tied to a symptom users feel, and make the first response a measurement rather than a guess. Record performance-relevant changes, such as new query patterns or payload growth, next to the alerts so correlation is fast. The pitfall is noisy resource alerts that drown out meaningful drift. Rule of thumb: alert on budget burn and drift, not on every metric that wiggles.$body$, $code$# Burn-rate alert on the p99 objective:
# 14x burn over 5 minutes, or 6x over 1 hour, pages the on-call.
# Drift check: this week vs last week at the same daily peak.
# First response to any alert is a measurement, not a guess.
# Alert on budget burn and drift, not on every metric.$code$)
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
    'java-performance-methodology', 'profiling-cpu-hotspots', 'memory-profiling-in-practice',
    'gc-tuning-in-practice', 'jit-compilation-and-warmup', 'throughput-vs-latency',
    'load-test-driven-tuning', 'database-performance-tuning', 'jdbc-and-pool-tuning',
    'serialization-performance', 'string-performance-java', 'collection-performance-java',
    'io-and-network-performance', 'async-io-and-reactor-performance',
    'performance-regression-prevention'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
