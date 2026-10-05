-- V31 — Observability engineering.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('observability-three-pillars', 'How Metrics Logs and Traces Work Together', 'See how metrics, logs, and traces complement each other and where each signal alone misleads.', 'Mid', 26, true, 1),
    ('structured-logging-in-java', 'Structured Logging in Java Services', 'Emit JSON log events with stable field names, disciplined levels, and no secrets or personal data.', 'Junior', 24, true, 1),
    ('log-aggregation-and-retention', 'Log Aggregation and Retention Tiers', 'Ship logs reliably, index only what you search, and retain older data at a lower cost.', 'Junior', 22, true, 1),
    ('micrometer-metrics-fundamentals', 'Micrometer Metrics Fundamentals', 'Instrument services with counters, gauges, timers, and histograms, and name every meter before writing code.', 'Mid', 28, true, 1),
    ('metric-cardinality-management', 'Managing Metric Cardinality', 'Keep metric series bounded by choosing tag dimensions deliberately and enforcing limits in code review.', 'Senior', 34, true, 1),
    ('histogram-percentiles-and-buckets', 'Histogram Percentiles and Bucket Design', 'Compute percentiles from histograms correctly, design buckets around SLO boundaries, and aggregate across instances.', 'Senior', 36, true, 1),
    ('prometheus-and-grafana-workflow', 'Prometheus and Grafana Workflow', 'Work the scrape pipeline end to end, from exposition format to recording rules and readable dashboards.', 'Mid', 30, true, 1),
    ('alerting-on-symptoms-not-causes', 'Alerting on Symptoms Not Causes', 'Write alerts that track user-visible SLOs, control burn rates, and ship with owners and runbooks.', 'Mid', 32, true, 1),
    ('distributed-tracing-with-opentelemetry', 'Distributed Tracing with OpenTelemetry', 'Instrument spans and attributes, choose head or tail sampling, and run a collector topology that keeps costs sane.', 'Senior', 38, true, 1),
    ('trace-context-propagation', 'Trace Context Propagation Across Boundaries', 'Carry W3C trace context across HTTP, messaging, and asynchronous boundaries without breaking the chain.', 'Senior', 34, true, 1),
    ('jvm-runtime-observability', 'JVM Runtime Observability Signals', 'Read heap, GC, thread pool, and connection pool metrics as early warnings instead of postmortem trivia.', 'Mid', 30, true, 1),
    ('health-checks-and-readiness-in-spring', 'Health Checks and Readiness in Spring', 'Configure Actuator health groups so orchestrators stop sending traffic to instances that cannot serve it.', 'Junior', 26, true, 1),
    ('profiling-in-production', 'Continuous Profiling in Production', 'Run continuous low-overhead profilers in production and connect profile samples to traces and releases.', 'Mid', 28, true, 1),
    ('error-tracking-and-exception-aggregation', 'Error Tracking and Exception Aggregation', 'Group exceptions into actionable issues with release tags, ownership routes, and deliberate noise reduction.', 'Mid', 26, true, 1),
    ('incident-debugging-with-observability', 'Debugging Incidents with Observability', 'Triage incidents with a disciplined loop over dashboards, exemplars, recent changes, and tested hypotheses.', 'Mid', 30, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('observability-three-pillars', 1, 'Three Signals Answer Three Questions', $body$Metrics are cheap aggregates that answer whether something is wrong and how bad; they are numeric time series suited to dashboards, alerting, and trend comparison. Logs are discrete events that answer what exactly happened for one request, with full payload context, at the cost of volume and parsing. Traces are causal call trees that answer where time went across service and network boundaries. In production, metrics detect, traces localize, and logs explain. Instrument all three from the same request path so an alert leads to a trace and the trace leads to correlated log lines instead of a manual hunt across disconnected tools.$body$, $code$// metric: cheap and aggregatable across instances
registry.counter("orders.placed").increment();

// log: one rich event for exactly this order
log.info("order.placed orderId={} totalCents={}", id, totalCents);

// trace: causal timeline shared across services
Span span = tracer.spanBuilder("place-order").startSpan();$code$),
    ('observability-three-pillars', 2, 'What Each Pillar Misses Alone', $body$Metrics aggregate away identity, so a latency alert cannot tell you which tenant or query caused the tail. Logs lack cross-service structure, so reconstructing one request flow across dozens of services means joining on request identifiers that may not exist. Traces sample, so rare errors can vanish unless error spans are kept, and they usually carry no high-cardinality payload such as response bodies. Relying on one signal creates blind spots: dashboards that cannot localize, log searches that cannot prove causality, and traces too sparse to alert on. The rule of thumb is to let each signal cover the gaps of the others rather than duplicating everything in all three.$body$, $code$String traceId = span.getSpanContext().getTraceId();
MDC.put("trace_id", traceId);
try {
    log.warn("payment.failed orderId={} reason={}", orderId, reason);
} finally {
    MDC.remove("trace_id");
}$code$),
    ('observability-three-pillars', 3, 'Correlating Signals by Design', $body$Correlation is an instrumentation decision, not a search feature. Put trace and span identifiers on every log line through structured logging context, expose exemplars that attach a trace identifier to histogram buckets, and keep a stable request identifier that survives asynchronous hops. Then a p99 panel spike links directly to a trace, and the trace links to exactly the log lines for that request. Without these keys, engineers settle for guessing by timestamp, which fails during traffic bursts when hundreds of requests share the same millisecond. Treat the join keys as part of the observability contract and test that they appear in every service template before an incident needs them.$body$, $code$registry.config().meterFilter(
    MeterFilter.commonTags(Tags.of("service", "orders")));

Timer.builder("orders.persist.latency")
    .publishPercentileHistogram()
    .register(registry)
    .record(Duration.ofMillis(141));$code$),
    ('structured-logging-in-java', 1, 'Emit JSON Events Not Prose', $body$Structured logging writes each event as a machine-parseable object instead of a sentence, so collectors can index fields without fragile regular expressions. Java frameworks support JSON through layouts or, in Spring Boot 3.4 and later, through built-in structured console formats configured with properties. Keep the message a constant template with parameter placeholders rather than concatenated strings; the parameters travel as separate fields. A fixed schema, typically timestamp, level, logger, message, plus your own fields, lets queries such as status equals 500 and tenant equals acme work years later. The moment format varies per team member, every downstream parser, dashboard, and alert rule breaks quietly.$body$, $code$static final Logger log = LoggerFactory.getLogger(OrderService.class);

void markPaid(String orderId, long cents) {
    log.info("order.paid orderId={} amountCents={}", orderId, cents);
}$code$),
    ('structured-logging-in-java', 2, 'Field Names and Level Discipline', $body$Stable field names matter more than pretty messages. Choose lowercase dotted or snake case keys once, document them, and reuse the same key for the same meaning across services; a rename is a breaking change for alerts and dashboards. Levels encode audience and urgency: ERROR means a human must act, WARN means something degraded but handled, INFO records state transitions worth keeping, DEBUG and TRACE are for temporary investigation. Logging every request at INFO turns search into noise and multiplies storage cost. Pick levels by asking who will act on this line, not by how the developer felt during the commit.$body$, $code$logging.structured.format.console=ecs
logging.structured.ecs.service.name=order-service
logging.structured.ecs.service.version=1.4.0
logging.level.root=INFO
logging.level.com.acme.orders=DEBUG$code$),
    ('structured-logging-in-java', 3, 'Never Log Secrets or PII', $body$Log pipelines are widely readable and retained for months, so anything written tends to become permanent and discoverable. Never log passwords, tokens, session identifiers, authorization headers, full card numbers, or unnecessary personal data; log a stable surrogate identifier instead. Prefer allowlists of fields on request and response logging over dumping whole objects, since serializers happily include whatever fields exist today and additions tomorrow. Add masking at the boundary, in a shared filter or encoder, rather than relying on every caller to remember. Treat a leaked token in logs like a leaked token anywhere else: rotate first, then fix the code path that wrote it.$body$, $code$String masked = "****" + cardNumber.substring(cardNumber.length() - 4);
log.info("payment.authorized orderId={} card={}", orderId, masked);

// Never write tokens, headers, or raw payloads:
// log.info("auth header={}", authorizationHeader);$code$),
    ('log-aggregation-and-retention', 1, 'Ship from the Host to Stdout', $body$Applications should write logs to standard output and let the platform collect them; writing files on a container filesystem loses data when the pod dies and complicates rotation. A collector agent, sidecar, or platform pipeline then ships events to the aggregation backend. The pipeline needs bounded buffering, because a backend outage with unbounded memory turns a logging problem into an availability problem; when buffers fill, decide explicitly whether to drop oldest, drop newest, or block. Include tenant and environment as resource attributes at the shipper so routing happens without parsing the message. Test the path end to end: a log line that never arrives is worse than one with an ugly format.$body$, $code$[INPUT]
    Name tail
    Path /var/log/app/*.json
    Tag  app.logs

[OUTPUT]
    Name  http
    Match app.logs
    Host  logs.internal
    Port  9200$code$),
    ('log-aggregation-and-retention', 2, 'Indexing Is the Expensive Part', $body$In most log platforms, ingestion and indexing dominate cost, not the raw bytes of storage. Every token indexed in a full-text engine becomes searchable and also consumes segments, merging, and memory. Index the fields you actually query: service, environment, level, trace identifier, and a few domain keys; keep large payloads stored but not indexed. Sampling debug logs during normal operation and enabling them per scope when needed keeps volume proportional to value. Before adding a field to the schema, ask which alert or dashboard will use it; if nothing queries it, do not pay to index it.$body$, $code${
  "level": "INFO",
  "service": "order-service",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "message": "order.paid",
  "payload": "stored-but-not-indexed"
}$code$),
    ('log-aggregation-and-retention', 3, 'Retention Tiers and Lifecycle', $body$Keep recent logs hot for fast search, then move older data to cheaper cold storage and expire it when its debugging or compliance value ends. Define tiers by search need: days of hot storage for incidents, weeks or months of warm data for audits, and object storage for rare retrieval. Automate transitions with index lifecycle policies or bucket lifecycle rules, and verify that restores work before you need one. Retention is also a privacy decision; personal data should not live longer than the purpose that justified collecting it. A vague forever default grows cost steadily and quietly, so choose explicit windows per log category.$body$, $code${
  "policy": {
    "phases": {
      "hot": { "actions": { "rollover": { "max_age": "1d" } } },
      "warm": { "actions": { "forcemerge": { "max_num_segments": 1 } } },
      "delete": { "min_age": "30d", "actions": { "delete": {} } }
    }
  }
}$code$),
    ('micrometer-metrics-fundamentals', 1, 'Match the Meter to the Question', $body$Counters only increase and answer how many events happened; they reset on restart, so query them with rate or increase functions rather than raw totals. Gauges report a current value such as queue depth or pool size and are sampled at scrape time, which means short spikes can be missed. Timers record durations and give count, total, and optionally a distribution; distribution summaries record arbitrary values with a scale. Choosing the wrong type creates awkward queries later, for example polling a counter into a gauge to fake a level. Decide the question first, then pick the meter that answers it directly.$body$, $code$Counter placed = registry.counter("orders.placed");
placed.increment();

Gauge.builder("orders.queue.depth", queue, q -> q.size())
    .register(registry);

Timer.builder("orders.persist.latency")
    .register(registry)
    .record(Duration.ofMillis(23));$code$),
    ('micrometer-metrics-fundamentals', 2, 'Name Meters Like an API', $body$Metric names are a public contract shared by dashboards, alerts, and other teams, so design them before instrumenting. Micrometer normalizes names per backend, so write lowercase dot-separated names such as orders.placed or orders.persist.latency and let the registry translate them. Include the domain, then the object, then the measurement: orders.persist.latency reads clearly; requestTimeMs does not specify domain or unit. Express units in the name or follow the base unit convention, and add backend-specific suffixes only through conventional transformations. Renames invalidate every historical graph and alert expression, which makes deliberate naming far cheaper than a later cleanup migration.$body$, $code$// Good: domain.object.measurement in dot notation
registry.timer("orders.persist.latency");
registry.counter("orders.placed");

// Avoid: vague, unitless, camel case
registry.timer("requestTimeMs");$code$),
    ('micrometer-metrics-fundamentals', 3, 'Timers and Long Tasks', $body$A timer records count, total time, and maximum; maximum decays slowly in some registries, so a single outlier can dominate a panel for a while. Create timers per logical operation with a bounded tag set, and record with a lambda, try-finally, or around advice so exceptions still produce a duration. For work measured in seconds or minutes, publishing a histogram with suitable buckets communicates more than a mean does. Remember that a timer around a blocking call measures queueing plus execution; wrap the wait separately if you want to separate saturation from work. Publish SLO-relevant timers with percentile histograms from day one so alerts can use quantiles later.$body$, $code$Timer timer = Timer.builder("orders.persist.latency")
    .publishPercentileHistogram()
    .register(registry);

Order saved = timer.record(() -> orderRepository.save(order));
return saved;$code$),
    ('metric-cardinality-management', 1, 'Why Series Counts Explode', $body$Every distinct combination of metric name and tag values is a separate time series, and each series costs memory in the time series database whether or not anyone looks at it. A tag such as user identifier, email, request identifier, or raw URL path multiplies cardinality by the number of distinct values, so one careless tag can turn a cheap counter into millions of series and slow every query for the whole tenant. Series churn is worse than steady cardinality because dead series leave tombstones and index churn. Treat the number of active series as a capacity budget like connection pools, and watch it after every release, since growth usually arrives with a feature rather than a single dramatic incident.$body$, $code$// Do not tag metrics with unbounded values.
registry.counter("http.requests", "path", request.getRequestURI());

// Normalize to a bounded template before tagging.
registry.counter("http.requests", "route", routePattern);$code$),
    ('metric-cardinality-management', 2, 'Choose Dimensions Deliberately', $body$A useful tag dimension is bounded, meaningful for aggregation or filtering, and stable over time. Good candidates include route template, status class, region, operation name, and result such as success or failure. Before adding a tag, estimate its distinct value count across a full year of traffic, including tenant-specific values in a multi-tenant system. If the exact value matters only for debugging one request, it belongs in logs or traces, not in metrics. When you need per-customer detail, create a bounded classification such as tier or plan instead of the customer identifier, and record the identifier only in sampled high-cardinality signals.$body$, $code$registry.counter("http.server.requests",
    "method", request.method(),
    "route", routePattern,
    "status", statusFamily,
    "region", regionCode).increment();$code$),
    ('metric-cardinality-management', 3, 'Enforce Cardinality in Review', $body$Cardinality rules fail when they live only in a wiki, so automate what you can. Add a review checklist item that every new tag has a documented bounded domain, run static checks for common mistakes such as tagging with identifiers or exception messages, and alert on series growth per metric and per job. Configure collection limits in the registry or scrape path to fail closed rather than letting a runaway tag take down the database. When limits trigger, drop the high-cardinality tag rather than the whole metric, so dashboards keep working while someone fixes the instrumentation. Review the top metrics by series count monthly and prune what nobody queries.$body$, $code$registry.config().meterFilter(
    MeterFilter.maximumAllowableTags(
        "http.server.requests", "route", 200,
        MeterFilter.deny()));

registry.config().meterFilter(
    MeterFilter.deny(id -> id.getTag("userId") != null));$code$),
    ('histogram-percentiles-and-buckets', 1, 'Why Averages and Naive Percentiles Lie', $body$Latency distributions are skewed, so the mean hides the slow requests users remember and can sit far below the median on bimodal traffic. Client-side percentiles computed per instance cannot be combined: averaging two p95 values is not the fleet p95, and taking the maximum overstates the population. Histograms avoid this because they keep bucket counts that can be summed across instances and time before a quantile is computed. Timers configured without percentile histograms publish only count, total, and maximum, which leaves you able to compute a mean but not a tail. If the service has an SLO on latency, publish a histogram for the relevant operations from the first release.$body$, $code$Timer.builder("http.server.requests")
    .publishPercentileHistogram()
    .serviceLevelObjectives(
        Duration.ofMillis(100),
        Duration.ofMillis(300))
    .register(registry);$code$),
    ('histogram-percentiles-and-buckets', 2, 'Design Buckets Around Decisions', $body$A histogram approximates a percentile by interpolation inside the bucket that contains the target rank, so bucket placement determines accuracy near the thresholds you alert on. Put explicit boundaries at SLO limits and typical contract values, for example 100, 200, 300, 500, 1000, and 2000 milliseconds, rather than accepting a generic exponential layout that misses your line. Too few buckets make p99 values coarse; too many increase series count and storage roughly linearly with boundary count. Prometheus native histograms remove the manual boundary choice, but classic buckets remain the widely supported default. Document why each boundary exists so future edits do not silently degrade alert accuracy.$body$, $code$# p95 latency across all instances
histogram_quantile(0.95,
  sum by (le) (rate(http_server_requests_seconds_bucket{job="api"}[5m])))

# share of requests slower than 300 ms
1 - sum(rate(http_server_requests_seconds_bucket{job="api",le="0.3"}[5m]))
  / sum(rate(http_server_requests_seconds_count{job="api"}[5m]))$code$),
    ('histogram-percentiles-and-buckets', 3, 'Aggregation Across Instances and Time', $body$The correct fleet-wide quantile sums bucket counters across every instance first, then applies the quantile function to the combined le series. Query with rate over a window to get per-second bucket growth, sum by le across pods, and only then call histogram_quantile; skipping the sum produces per-pod curves and alerts that flap as replicas scale. Choose a window longer than the scrape interval and long enough to smooth noise, often five minutes for alerts and shorter for live dashboards. Because bucket boundaries are fixed at instrument time, any later aggregation can only be as accurate as the original layout. Keep an eye on quantile error near boundaries by comparing with a second window during drills.$body$, $code$groups:
  - name: latency
    rules:
      - record: job:http_request_latency_seconds_bucket:rate5m
        expr: sum by (job, le) (rate(http_server_requests_seconds_bucket[5m]))
      - record: job:http_request_latency_seconds:p95
        expr: histogram_quantile(0.95, job:http_request_latency_seconds_bucket:rate5m)$code$),
    ('prometheus-and-grafana-workflow', 1, 'The Pull Model and Exposition', $body$Prometheus discovers targets and pulls metrics over HTTP on a fixed interval; each target exposes current values in a text format at a known path, commonly the Actuator Prometheus endpoint in a Spring Boot service. Because collection is pull-based, staleness is visible: a missing scrape shows up as an absent series and a target health page, not a silent gap. Counters are exposed as monotonically increasing values and only become rates inside queries. Scrape intervals and timeouts are budgets: tighter intervals improve resolution but multiply samples, storage, and rule evaluation cost. Keep the exporter endpoint read-only and cheap, and never do request-scoped work in the scrape path.$body$, $code$scrape_configs:
  - job_name: order-service
    metrics_path: /actuator/prometheus
    scrape_interval: 15s
    static_configs:
      - targets: ["order-service:8080"]$code$),
    ('prometheus-and-grafana-workflow', 2, 'Recording and Alerting Rules', $body$Express dashboards with raw queries until you notice the same slow expression copied everywhere; then promote it to a recording rule with a consistent name such as job:http_requests:rate5m and reference the precomputed series. Recording rules evaluate on an interval and store the result as a normal series, which keeps heavy aggregations off dashboard load time and gives alerts a stable name to target. Alerting rules should reference those recorded series, include a clear summary and description, and set for durations that suppress transient blips without delaying real outages. Keep rule files in version control, test them in a staging Prometheus, and treat every expression change like a code change with review.$body$, $code$groups:
  - name: orders
    rules:
      - record: job:http_requests:rate5m
        expr: sum by (job) (rate(http_server_requests_seconds_count[5m]))
      - alert: RequestRateDrop
        expr: job:http_requests:rate5m < 0.5
        for: 5m
        labels:
          severity: warning$code$),
    ('prometheus-and-grafana-workflow', 3, 'Dashboards People Actually Use', $body$A production dashboard should answer whether the service is healthy in the first row, using the four golden signals: latency, traffic, errors, and saturation. Group panels by question, not by metric source, and keep one legend convention so every panel reads the same way. Avoid vanity panels that no incident ever references; if a panel has not influenced an action, remove it or move it to a drill-down dashboard. Use variables for environment and instance to avoid duplicating whole dashboards, set sane default time ranges, and add deployment annotations so change events appear inline. Link each alert to the exact dashboard and time window it needs.$body$, $code$# rate
sum by (job) (rate(http_server_requests_seconds_count[5m]))
# errors
sum by (job) (rate(http_server_requests_seconds_count{status=~"5.."}[5m]))
# latency p95
histogram_quantile(0.95, sum by (le) (rate(http_server_requests_seconds_bucket[5m])))$code$),
    ('alerting-on-symptoms-not-causes', 1, 'Alert on What Users Feel', $body$Symptom-based alerts fire when users are affected: error ratio above the objective, latency beyond the target, or completed work falling behind. Cause-based alerts, such as a single pod with high heap or one node with elevated CPU, are better expressed as investigative signals or tickets, because headroom routinely absorbs such conditions without any user impact. Pages should be rare enough that engineers trust them; every page that required no action trains people to ignore the next one. Before writing an expression, name the user-visible condition it approximates and the action the responder should take; if the action is just to look, it probably belongs on a dashboard.$body$, $code$- alert: CheckoutErrorsBurningBudget
  expr: |
    sum(rate(http_server_requests_seconds_count{job="checkout",status=~"5.."}[5m]))
      / sum(rate(http_server_requests_seconds_count{job="checkout"}[5m])) > 0.05
  for: 5m
  labels:
    severity: page$code$),
    ('alerting-on-symptoms-not-causes', 2, 'Burn Rates and Multiwindow Checks', $body$Error budgets turn reliability into arithmetic: if the SLO allows 0.1 percent errors over 30 days, a burn rate of 14.4 consumes the entire budget in roughly 50 hours. Multiwindow alerting pairs a long window that proves the problem is sustained with a short window that proves it is still happening, which gives fast detection for severe outages and slower detection for slow burns. Thresholds and windows come from the SLO document, not from taste, so alert behavior changes only when the objective changes. Review burn-rate alerts after incidents to confirm they fired early enough and did not page for harmless spikes.$body$, $code$# Fast burn: a 30-day budget at 14.4x would exhaust in about 50 hours.
expr: |
  (
    sum(rate(http_server_requests_seconds_count{status=~"5.."}[1h]))
    / sum(rate(http_server_requests_seconds_count[1h]))
  ) > (14.4 * 0.001)
for: 2m$code$),
    ('alerting-on-symptoms-not-causes', 3, 'Runbooks Ownership and Routing', $body$Every paging alert needs an owner team, a route, and a runbook that fits on one screen: what the alert means, how to confirm it, first checks, likely causes, and when to escalate. Store runbooks next to the rule and link them from the alert annotation so a responder is one click from guidance at three in the morning. Route by ownership rather than by severity alone, and let severity control interruption level: pages for user impact, tickets for degradation, silence for known churn. Alerts without owners accumulate as failure signals themselves; if no team will commit to a response, convert the alert into a dashboard panel.$body$, $code$annotations:
  summary: "Checkout error ratio above SLO"
  runbook_url: "https://runbooks.acme.dev/checkout-errors"
  dashboard: "https://grafana.acme.dev/d/checkout"
labels:
  team: payments
  severity: page$code$),
    ('distributed-tracing-with-opentelemetry', 1, 'Spans Attributes and Events', $body$A trace is a tree of spans, each recording an operation name, start and end time, a parent relationship, and attributes. Attributes should be low-cardinality and cheap: route templates, status codes, peer service names, versions. Put high-cardinality detail, such as an order identifier, in span events only when it is genuinely useful, and remember that attributes are indexed by most backends while events are generally not. Span names should describe the operation, not the request data, so aggregation works. Keep span counts per request bounded; a loop that creates a span per row generates cost without adding diagnostic value, and deep trees exceed backend limits. Follow semantic conventions for common operations so backend features and dashboards work out of the box.$body$, $code$Span span = tracer.spanBuilder("payment.charge")
    .setSpanKind(SpanKind.CLIENT)
    .startSpan();
try (Scope scope = span.makeCurrent()) {
    span.setAttribute("payment.provider", provider);
    return gateway.charge(request);
} finally {
    span.end();
}$code$),
    ('distributed-tracing-with-opentelemetry', 2, 'Head and Tail Sampling', $body$Head-based sampling decides at trace start and propagates the decision, so a parent-based sampler keeps whole traces consistent across services at very low overhead. A ratio sampler scales traffic down, but it decides before the outcome is known, so rare errors and slow outliers are missed at low rates. Tail-based sampling buffers complete traces in a collector and decides after seeing the whole trace, allowing rules such as keep all errors and slow traces while sampling the rest. It costs memory and routing effort and needs every span of a trace to reach the same deciding collector, typically through consistent routing by trace identifier. Many teams combine both: a permissive head sampler plus tail policies for what matters.$body$, $code$processors:
  tail_sampling:
    decision_wait: 10s
    policies:
      - name: keep-errors
        type: status_code
        status_code: {status_codes: [ERROR]}
      - name: slow-traces
        type: latency
        latency: {threshold_ms: 500}$code$),
    ('distributed-tracing-with-opentelemetry', 3, 'Collector Topology and Export', $body$The OpenTelemetry Collector decouples applications from backends: services export OTLP to a local or in-cluster collector, which batches, redacts, samples, and fans out to one or more backends. A common topology runs an agent collector near workloads for enrichment and batching, plus a gateway collector for tail sampling and routing, so backends can be swapped without redeploying applications. Batching reduces export overhead but adds latency and memory; configure maximum batch size and timeout based on trace volume. Watch the collector itself as a production service: queue length, refused spans, and export failures are the metrics that explain missing data after an incident.$body$, $code$service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, tail_sampling]
      exporters: [otlphttp/backend]
  telemetry:
    metrics:
      level: detailed$code$),
    ('trace-context-propagation', 1, 'The traceparent Header Contract', $body$W3C Trace Context defines a traceparent header of the form version, 32 hexadecimal trace identifier, 16 hexadecimal parent span identifier, and flags; the sampled flag in the last field tells downstream services whether to record. Version 00 is the current specification, and a compliant implementation must accept it, treat unknown future versions conservatively, and never invent identifiers when parsing fails. Because the format is standardized, gateways, proxies, runtimes, and vendors exchange context without custom adapters. The practical failures are mundane: intermediaries strip unknown headers, old client libraries drop flags, and code that regenerates identifiers mid-flight creates a second disconnected trace. Verify propagation with one request that crosses every hop in the real topology.$body$, $code$traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
tracestate: acme=00000000000000000000000000000001

TextMapGetter<HttpHeaders> getter = new TextMapGetter<>() {
    public Iterable<String> keys(HttpHeaders carrier) { return carrier.keySet(); }
    public String get(HttpHeaders carrier, String key) { return carrier.getFirst(key); }
};
Context extracted = W3CTraceContextPropagator.getInstance()
    .extract(Context.current(), headers, getter);$code$),
    ('trace-context-propagation', 2, 'Async and Messaging Boundaries', $body$Context is stored per thread in most Java instrumentation, so handing work to an executor or a reactive pipeline without wrapping loses the current span. Capture the context at submission time and run the task inside it; reactive frameworks and OTel integrations usually provide a context-propagation wrapper for schedulers instead of manual work. For messaging, producers inject context into message headers or attributes, and consumers extract it into the receiving context, so one trace spans across the broker. Batch consumers must extract per record, since each message can belong to a different trace, and a single consumer span should be a child of that record context. Idle-thread reuse makes missing wrappers intermittent, which is exactly why they escape review.$body$, $code$Context context = Context.current();
executor.execute(context.wrap(() ->
    paymentService.settle(orderId)));

// Messaging: inject on produce, extract on consume
propagator.inject(Context.current(), message, setter);
Context parent = propagator.extract(Context.root(), record, getter);$code$),
    ('trace-context-propagation', 3, 'Propagating Across Multi-Protocol Boundaries', $body$Propagation is only as good as the weakest hop, so inventory every protocol a request crosses: HTTP, gRPC, Kafka, JMS, database drivers, batch files, and third-party APIs. Most instrumented clients inject automatically when a current context exists; manual injection is needed for custom protocols, legacy gateways, and places where an intermediary rewrites headers. If an external partner does not accept trace headers, treat that boundary as a new root and correlate with your own request identifier in logs instead of pretending the trace continues. Sampling decisions must survive every hop too, which is why the propagator carries flags rather than each service deciding again. Document the propagation map once and test the seams with contract tests.$body$, $code$// gRPC clients inject via Metadata when instrumented
Metadata metadata = new Metadata();
propagator.inject(Context.current(), metadata,
    (carrier, key, value) -> carrier.put(
        Metadata.Key.of(key, Metadata.ASCII_STRING_MARSHALLER), value));$code$),
    ('jvm-runtime-observability', 1, 'Heap GC and Allocation Signals', $body$For a JVM, the leading indicators of trouble are allocation rate, garbage collection pause time, and the size of the live set after collection. Rising allocation rate with stable traffic usually means a code path changed; a growing live set after full collections points at a leak or a cache without eviction. Pause panels should show both frequency and duration, since many short pauses and a few long ones degrade latency differently. Micrometer exposes jvm.gc.pause as a timer with cause tags and jvm.memory.used per pool, which is enough to build an early-warning dashboard. Track these as trends across deployments rather than absolute thresholds, because heap layout and tuning differ per service.$body$, $code$# GC pause p99 per service
histogram_quantile(0.99,
  sum by (le, job) (rate(jvm_gc_pause_seconds_bucket[5m])))

# fraction of wall time spent in GC
sum by (job) (rate(jvm_gc_pause_seconds_sum[5m]))$code$),
    ('jvm-runtime-observability', 2, 'Thread Pools as Saturation Gauges', $body$Web server threads and task executors show saturation before latency collapses: active threads near maximum with a growing queue means work arrives faster than it drains. Monitor active, idle, pool size, and queue depth for each executor, plus rejection counts where the pool has an abort policy. A queue that never returns to zero after peak is the signature of a leak or a slow downstream dependency, not a capacity limit. Instrument custom executors explicitly, since only framework-managed ones are auto-instrumented. Set alerts on the trend of queue depth rather than instantaneous values, and always compare with request rate to distinguish load from a stall.$body$, $code$// Instrument custom executors explicitly.
ThreadPoolExecutor pool = new ThreadPoolExecutor(
    8, 8, 0, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>(500));
new ExecutorServiceMetrics(pool, "orders.worker", Tags.empty())
    .bindTo(registry);$code$),
    ('jvm-runtime-observability', 3, 'Connection Pools Predict Incidents', $body$A database connection pool is a queue with a hard limit, and its metrics predict incidents earlier than request latency does. Watch pending threads waiting for a connection, acquisition time, usage against maximum pool size, and timeouts; a pending count rising while active is at max means the database or long transactions are the bottleneck. Timeouts are especially damaging because they surface as application errors unrelated to query content. HikariCP exposes these through Actuator as hikaricp.connections.active, pending, timeout, and max when Micrometer and the HikariDataSource are both present. Alarm on sustained pending work and timeout rate, and size the pool from database capacity, not from the number of application threads.$body$, $code$management.metrics.enable.hikaricp=true
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=2000
# alert on hikaricp_connections_pending and hikaricp_connections_timeout_total$code$),
    ('health-checks-and-readiness-in-spring', 1, 'Liveness Versus Readiness', $body$Liveness answers whether the process should be restarted; readiness answers whether it should receive traffic. A liveness check must be cheap and independent of external dependencies, because a restart does not fix a broken database and can turn one outage into a crash loop. A readiness check should verify the things needed to serve requests, such as database connectivity when the service cannot function without it. During startup, readiness should report down while the application warms up, so load balancers wait instead of failing requests. Mislabeling them is a classic cause of cascading failures: restarts triggered by dependency outages amplify incidents rather than containing them.$body$, $code$livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 30
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  periodSeconds: 5$code$),
    ('health-checks-and-readiness-in-spring', 2, 'Health Groups in Actuator', $body$Actuator aggregates health indicators into an overall status, and groups let you ask a narrower question with its own membership. Define a readiness group that includes readiness state plus the dependencies required to serve traffic, and a liveness group that contains only the liveness state and genuinely fatal conditions. Indicators carry a status such as UP, DOWN, or OUT_OF_SERVICE, and group configuration chooses what is included; detail exposure is controlled by show-details. Keep the default health endpoint for load balancers and humans, and point orchestrator probes at the group endpoints. Review group membership whenever a new dependency is added, because an unlisted indicator silently stops protecting traffic routing.$body$, $code$management.endpoint.health.probes.enabled=true
management.endpoint.health.group.readiness.include=readinessState,db
management.endpoint.health.group.liveness.include=livenessState
management.endpoint.health.group.readiness.show-details=when-authorized
management.endpoint.health.status.http-mapping.down=503$code$),
    ('health-checks-and-readiness-in-spring', 3, 'Dependency-Aware Health Checks', $body$A readiness check that calls every downstream service converts any dependency blip into a traffic removal for a service that could still degrade gracefully. Include only dependencies whose absence makes this instance unable to serve meaningfully, and prefer a bounded, cached check over a deep query: a health endpoint must answer in milliseconds, not run business logic. Never let the health check write data or start work, and set short timeouts so the probe thread cannot hang. For expensive dependencies, track them in metrics and dashboards instead of readiness. A custom contributor belongs when it reports a real, cheap functional fact about the instance, not merely that a client bean exists.$body$, $code$@Component
class QueueBacklogHealth implements HealthIndicator {
    public Health health() {
        long depth = queue.depth();
        return depth < 10_000
            ? Health.up().withDetail("depth", depth).build()
            : Health.down().withDetail("depth", depth).build();
    }
}$code$),
    ('profiling-in-production', 1, 'From Ad Hoc to Continuous Profiles', $body$Traditional profiling happens on a developer machine or in a one-off production session, which misses the rare, load-dependent behavior that causes incidents. Continuous profiling samples CPU, allocation, or lock stacks across the whole fleet all the time, aggregating by service, version, and region, so regressions appear as changes in hot methods between releases. The value is comparative: profiles are most useful as flame graphs diffed across versions or deployments, not as one static picture. Keep profiles aggregated and labeled rather than storing every raw sample forever, and decide the retention window from how far back engineers actually compare. Start with CPU and wall-clock profiles, then add allocation and lock profiles where they answer real questions.$body$, $code$# Built-in JFR: low-overhead recording on a running JVM
jcmd <pid> JFR.start name=prof settings=profile duration=120s filename=app.jfr

# async-profiler: sample CPU for one minute and emit a flame graph
asprof -e cpu -d 60 -f cpu.html <pid>$code$),
    ('profiling-in-production', 2, 'Sampling with Predictable Overhead', $body$Sampling profilers interrupt execution at a fixed frequency, so overhead is roughly proportional to sample rate and stays in the low single-digit percent range; instrumenting profilers that record every call do not belong in production. Choose the event that matches the question: CPU samples find hot computation, wall-clock samples expose blocking and lock waits, allocation samples find churn, and lock profiles locate contention. Keep the sampler budget visible as configuration and measure it on a canary before fleet-wide enablement. Overhead also depends on stack depth and on collection frequency for the aggregation backend, so measure both the process and the pipeline when tuning. Predictability matters more than the absolute number.$body$, $code$# profile settings include stack traces and are safe for production
jcmd <pid> JFR.start name=prof settings=profile duration=300s \
  filename=/var/profiles/app.jfr
# check recordings and stop early if needed
jcmd <pid> JFR.check
jcmd <pid> JFR.stop name=prof$code$),
    ('profiling-in-production', 3, 'Correlating Profiles with Traces', $body$Profiles explain why a span was slow, so the useful workflow starts from a latency panel, opens a trace, and jumps to profile samples filtered by the same service, version, and time window. Some profilers accept labels or tags on samples that carry trace and span identifiers, enabling that jump directly; otherwise correlate by timestamp and version. Attach deployment markers so a flame graph diff lines up with the release that changed it. Store profile labels with bounded cardinality, because the same cardinality rules that apply to metrics apply to profile indexing. A review ritual of comparing top frames before and after each significant release catches regressions while they are cheap to fix.$body$, $code$# Jump from a slow trace to profiles: same service, version, and minute
profile query --service orders --version 1.4.2 \
  --from 2026-10-05T10:42Z --to 2026-10-05T10:43Z
# Compare hot frames across releases after a deploy marker
profile diff --service orders --baseline 1.4.1 --target 1.4.2$code$),
    ('error-tracking-and-exception-aggregation', 1, 'Grouping and Fingerprints', $body$Error trackers group exceptions into issues using a fingerprint built from exception type, message, and stack trace frames. Dynamic values in messages, such as identifiers or timestamps, fragment one root cause into thousands of issues unless the tracker normalizes them or you supply a stable fingerprint. Prefer exception types and a short cause key over free text, and keep custom grouping rules reviewed like code. Aggregation is what converts volume into signal: counts, users affected, and first or last seen matter more than a single occurrence. Deduplicate close to the source where possible, and attach the trace identifier so one representative occurrence is enough to investigate.$body$, $code$Sentry.captureException(ex, event -> {
    event.setFingerprint(new String[] {
        "checkout", ex.getClass().getName(), stableSubReason(ex)
    });
    return event;
});$code$),
    ('error-tracking-and-exception-aggregation', 2, 'Release and Environment Tags', $body$An error issue is only actionable with context: which release introduced it, whether it is production or staging, and which users see it. Tag events with release version, environment, region, and service at the client or logger boundary so grouping and filtering work without manual inspection. Release tagging turns error tracking into regression detection: after a deploy, watch new issues and rising rates for the version you just shipped. Environment separation prevents staging noise from inflating production counters and prevents an engineer from chasing a test failure at scale. Because release tags come from the build, inject the version once at packaging time and read it everywhere.$body$, $code$Sentry.withScope(scope -> {
    scope.setTag("release", buildVersion);
    scope.setTag("environment", environment);
    scope.setTag("service", "checkout");
    Sentry.captureException(ex);
});$code$),
    ('error-tracking-and-exception-aggregation', 3, 'Ownership Routing and Noise Reduction', $body$Route issues by code ownership, using paths in the stack trace as a proxy when a monolith maps to multiple teams, so the right group is paged rather than a shared channel. Set severity by user impact and frequency, and configure rate limits so a loop cannot flood the tracker or the on-call rotation. Fix noise at the source: expected exceptions used for control flow should be handled, not reported; handled degradation can be a log or metric instead of an error issue. Reserve issue creation for conditions a human should eventually act on, and mark everything else as operational data. Review the top issues monthly and close or fix the long tail deliberately.$body$, $code$# Example routing config: path prefix to owner team
owners:
  - path: "com.acme.checkout."
    team: checkout
  - path: "com.acme.payments."
    team: payments
rate_limit: 100_per_minute$code$),
    ('incident-debugging-with-observability', 1, 'A Triage Loop Not a Scavenger Hunt', $body$Start from the user-visible symptom and its SLO, not from the loudest alert: what exactly is failing, for which users, and since when. Check the golden signals for the affected path to bound impact, then narrow by dimension such as region, tenant, or version before diving into any single service. Write each hypothesis down with the observation that would confirm or refute it, and change one thing at a time. This discipline prevents tunneling on the first plausible cause and gives the incident channel an auditable trail when handing off. Most incidents resolve by excluding the boring causes quickly, so keep the loop tight and resist reading every dashboard before forming the first question.$body$, $code$# How bad, and since when?
sum(rate(http_server_requests_seconds_count{status=~"5.."}[1m]))

# Narrow by dimension before opening any single service
sum(rate(http_server_requests_seconds_count{status=~"5.."}[1m])) by (region)$code$),
    ('incident-debugging-with-observability', 2, 'Recent Changes and Deploy Markers', $body$Most production incidents follow a change: a deploy, configuration push, feature flag, dependency upgrade, or infrastructure event. Anchor the timeline with deployment annotations on dashboards and correlate the first bad minute with the nearest change rather than with the loudest symptom. Compare instance or version tags to see whether the problem is fleet-wide or limited to the new revision, which immediately supports or kills a change-related hypothesis. Roll back first when the signal points at a recent release and the change is cheap to reverse; investigation can continue on the reverted state. Keep a deploy log with exact version identifiers, because ambiguous timestamps waste the most valuable minutes.$body$, $code$# Is the failure limited to the new revision?
sum(rate(http_server_requests_seconds_count{status=~"5.."}[5m])) by (version)

# Line this up with the deploy marker annotation at the first bad minute
# and with the deploy log entry for the same minute$code$),
    ('incident-debugging-with-observability', 3, 'Exemplars to the Exact Request', $body$Once impact is bounded, exemplars connect aggregate panels to individual traces, ending the question of which request was slow. A p99 spike with an exemplar gives one trace identifier; that trace shows which span consumed the time and which instance hosted it, and structured logs supply the parameters. Without exemplars, pick a representative window, filter traces by latency and route, and keep the trace identifier in your notes. Confirm the cause by testing a prediction: if a slow dependency is responsible, its own latency panel and connection pool metrics should move first. Verification distinguishes a real mechanism from a coincidence that happened during the same five minutes.$body$, $code$# Quantile panels carry exemplars; click one to open the trace
histogram_quantile(0.99,
  sum by (le) (rate(http_server_requests_seconds_bucket{job="checkout"}[5m])))

# In the trace, read the critical path and the slowest span attributes$code$)
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
    'observability-three-pillars', 'structured-logging-in-java', 'log-aggregation-and-retention',
    'micrometer-metrics-fundamentals', 'metric-cardinality-management', 'histogram-percentiles-and-buckets',
    'prometheus-and-grafana-workflow', 'alerting-on-symptoms-not-causes', 'distributed-tracing-with-opentelemetry',
    'trace-context-propagation', 'jvm-runtime-observability', 'health-checks-and-readiness-in-spring',
    'profiling-in-production', 'error-tracking-and-exception-aggregation', 'incident-debugging-with-observability'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
