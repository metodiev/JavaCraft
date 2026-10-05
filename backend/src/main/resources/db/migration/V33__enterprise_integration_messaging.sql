-- V33 — Enterprise integration and messaging.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('messaging-vs-http-integration', 'Messaging versus HTTP Integration', 'Compare asynchronous messaging with synchronous calls and decide which one a workflow genuinely needs.', 'Junior', 24, true, 1),
    ('jms-fundamentals', 'JMS Fundamentals', 'Work with JMS queues, topics, acknowledgement modes, selectors, and Spring listeners without losing messages.', 'Junior', 26, true, 1),
    ('rabbitmq-with-spring-amqp', 'RabbitMQ with Spring AMQP', 'Model AMQP routing with exchanges and bindings, tune consumers with prefetch, and route failures to dead letters.', 'Mid', 32, true, 1),
    ('message-ordering-and-partitioning', 'Message Ordering and Partitioning', 'Reason about where message order is guaranteed and design partitions that combine sequence with parallelism.', 'Senior', 40, true, 1),
    ('message-idempotency', 'Message Idempotency in Consumers', 'Accept at-least-once delivery as normal and build consumers that tolerate repeated messages.', 'Mid', 30, true, 1),
    ('poison-messages-and-dlq', 'Poison Messages and Dead Letter Queues', 'Detect unprocessable messages, route them to dead letter queues, and replay them safely.', 'Mid', 34, true, 1),
    ('spring-integration-basics', 'Spring Integration Basics', 'Compose channels, transformers, routers, and gateways and know when a messaging DSL earns its abstractions.', 'Mid', 30, true, 1),
    ('apache-camel-for-integration', 'Apache Camel for Integration', 'Write Camel routes with endpoints and enterprise integration patterns, then test them with mock endpoints.', 'Senior', 38, true, 1),
    ('batch-processing-with-spring-batch', 'Batch Processing with Spring Batch', 'Structure jobs and chunk-oriented steps that restart safely and scale through partitioning.', 'Mid', 36, true, 1),
    ('scheduling-and-quartz', 'Scheduling with Quartz', 'Read cron expressions correctly, choose misfire policies, and run clustered schedules without duplicate execution.', 'Mid', 30, true, 1),
    ('file-and-ftp-integration', 'File and FTP Integration', 'Poll inbound files and remote directories, detect partial writes, and archive what was ingested.', 'Junior', 28, true, 1),
    ('soap-and-legacy-integration', 'SOAP and Legacy Integration', 'Generate WSDL-first clients, handle SOAP faults, and wrap legacy services behind modern APIs.', 'Mid', 32, true, 1),
    ('webhooks-outbound-and-inbound', 'Webhooks Outbound and Inbound', 'Deliver webhooks with retries and signatures, and receive them idempotently and safely.', 'Mid', 30, true, 1),
    ('email-and-notification-pipelines', 'Email and Notification Pipelines', 'Render notification templates, accept imperfect delivery, and control bounces and notification volume.', 'Junior', 24, true, 1),
    ('integration-testing-across-systems', 'Integration Testing Across Systems', 'Verify cross-system flows with containers and contracts while keeping test data lifecycle clean.', 'Senior', 42, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('messaging-vs-http-integration', 1, 'Coupling in Time and Contracts', $body$HTTP couples callers to the availability and latency of the callee: if the downstream service is down or slow, the caller waits, times out, or fails. A message broker inserts durable storage between them, so a producer can finish its work even when consumers are unavailable, and consumers can scale, restart, or deploy independently. The cost is that the result is no longer part of the caller transaction, failures surface later, and the system needs retries, deduplication, monitoring, and operational skill to run a broker. Choose asynchrony when work can complete later and losing the immediate response is acceptable; do not adopt it merely because it looks decoupled on a diagram.$body$, $code$// synchronous: the caller waits and inherits the failure
OrderResult result = billingClient.place(request);

// asynchronous: publish and let the consumer work at its own pace
messaging.convertAndSend("orders.created", order.id());$code$),
    ('messaging-vs-http-integration', 2, 'What Asynchrony Costs in Production', $body$Asynchrony does not remove failure; it moves failure in time and space. A produced message may be duplicated, delayed, or delivered after the business situation that created it has changed, so consumers must tolerate replays and out-of-order arrival. Operationally you now own a broker: disk, memory, upgrades, queue depth, and poison messages. Debugging spans several processes, so correlation identifiers and trace propagation become mandatory rather than nice to have. The trade-off deserves stating explicitly: you exchange a simple call stack for a durable buffer plus delivery semantics you must design. Teams that treat the broker as invisible infrastructure usually discover these costs during their first incident.$body$, $code$jmsTemplate.send("orders.created", session -> {
    TextMessage message = session.createTextMessage(payload);
    message.setStringProperty("correlationId", requestId);
    message.setStringProperty("traceId", MDC.get("traceId"));
    return message;
});$code$),
    ('messaging-vs-http-integration', 3, 'When a Synchronous Call Is Correct', $body$Use synchronous request response when the caller genuinely needs the result to continue, when the user is waiting and the work is short, or when a shared invariant must be checked immediately, such as reserving stock before confirming a purchase. A direct call is also correct when volume is low and the callee is highly available, because fewer moving parts mean fewer failure modes. The rule of thumb: if an answer is required within the request window, keep it synchronous and add timeouts, retries, and circuit breakers; if the work can finish later, publish a message. Do not mix both patterns for one workflow without deciding which path owns the outcome.$body$, $code$// the caller needs the answer before continuing
boolean reserved = inventory.reserve(sku, quantity);
if (!reserved) {
    throw new OutOfStockException(sku);
}$code$),
    ('jms-fundamentals', 1, 'Queues and Topics Compared', $body$A queue delivers each message to one consumer, so work is distributed and a message is not processed twice by competing readers, though redelivery can still happen after failures. A topic delivers a copy to every subscription, which suits broadcasting facts such as price changes or cache invalidations. Non-durable subscriptions lose messages while their subscriber is offline, while durable subscriptions retain them until they are acknowledged, which is usually required for production consumers. Pick queues for commands that must be executed once by one worker and topics for events that many independent consumers care about. Mixing the two roles in one destination makes ownership and scaling ambiguous.$body$, $code$// queue: exactly one competing consumer handles each message
jmsTemplate.convertAndSend("orders.work", command);

// topic: every durable subscription receives its own copy
jmsTemplate.convertAndSend("orders.events", event);$code$),
    ('jms-fundamentals', 2, 'Acknowledgement Modes and Redelivery', $body$JMS defines acknowledgement modes that decide when the broker may discard a message. AUTO_ACKNOWLEDGE acknowledges when the listener returns, which can lose a message if the process crashes before the business transaction commits. CLIENT_ACKNOWLEDGE lets the application acknowledge explicitly, giving control over timing but requiring care to acknowledge after durable work is done. DUPS_OK_ACKNOWLEDGE permits duplicates in exchange for performance. SESSION_TRANSACTED groups sends and acknowledgements into a transaction that commits atomically. Whatever you choose, assume redelivery is possible: JMS marks retried messages with JMSRedelivered, and your consumer must be safe when the same message arrives twice.$body$, $code$@Bean
DefaultJmsListenerContainerFactory factory(
        ConnectionFactory connectionFactory) {
    DefaultJmsListenerContainerFactory factory =
        new DefaultJmsListenerContainerFactory();
    factory.setConnectionFactory(connectionFactory);
    factory.setSessionTransacted(true);
    factory.setConcurrency("2-4");
    return factory;
}$code$),
    ('jms-fundamentals', 3, 'Spring Listeners and Selectors', $body$Spring wraps raw JMS with JmsTemplate for sending and @JmsListener methods for receiving, so you rarely touch sessions or acknowledgement APIs directly. A listener method can accept the payload or a full Message when headers matter, and selectors filter which messages a consumer receives, for example JMSType = 'order' AND priority > 5 evaluated against headers and properties. Keep selectors simple and indexed by broker semantics, because complex expressions are hard to reason about during incidents. Configure message conversion explicitly for your payload types, and treat the destination name and selector as part of the consumer contract. The container manages concurrency and redelivery; your code owns idempotency and validation of each payload.$body$, $code$@JmsListener(destination = "orders.created",
    selector = "JMSType = 'order' AND priority > 5")
public void onOrder(OrderEvent event) {
    handler.handle(event);
}$code$),
    ('rabbitmq-with-spring-amqp', 1, 'Exchanges Routing Keys and Bindings', $body$AMQP routing is a two-step model: a producer publishes to an exchange, and bindings decide which queues receive the copy. A direct exchange matches the routing key exactly, a topic exchange matches wildcard patterns such as order.*.created, a fanout exchange ignores the key and copies to every bound queue, and a headers exchange routes on message attributes. The default exchange routes by queue name, which is convenient for simple work queues but hides the topology. Design names as a contract: exchange and routing key together define who hears which event. Changing a binding is a deployment concern, so keep them declared in configuration rather than created by hand in the management console.$body$, $code$@Bean
Binding bindOrders(Queue orders, TopicExchange exchange) {
    return BindingBuilder.bind(orders)
        .to(exchange)
        .with("order.*.created");
}$code$),
    ('rabbitmq-with-spring-amqp', 2, 'Dead Lettering and Rejection', $body$A dead letter exchange is configured per queue with the x-dead-letter-exchange argument, and republished messages keep their original headers plus a reason. RabbitMQ dead-letters a message when a consumer rejects or negatively acknowledges it without requeue, when its time to live expires, when a queue hits its length limit, or when a quorum queue exceeds its delivery limit. The DLX is an ordinary exchange, so bind a queue to it and alarm on that queue depth. Spring AMQP rejects failing messages by default instead of requeueing them forever, because infinite redelivery of a deterministic failure blocks progress. Retry a bounded number of times, then let the message move to the dead letter path for inspection.$body$, $code$@Bean
Queue orders() {
    return QueueBuilder.durable("orders.created")
        .deadLetterExchange("orders.dlx")
        .deadLetterRoutingKey("orders.failed")
        .build();
}$code$),
    ('rabbitmq-with-spring-amqp', 3, 'Prefetch and Consumer Tuning', $body$Prefetch, also called basic.qos, limits how many unacknowledged messages a consumer holds at once. A high prefetch keeps a busy consumer fed but lets one slow consumer hoard work while others idle; a low prefetch improves fairness at the cost of more round trips. With manual acknowledgement and long processing, set prefetch close to the concurrency level, and increase it only when you observe idle consumers waiting on the broker. Manual acknowledgement must be paired with bounded retries, because acknowledgement is what lets the broker finally release the message. Measure queue depth and unacknowledged counts together: depth alone hides the case where every message is already claimed by stalled consumers.$body$, $code$spring:
  rabbitmq:
    listener:
      simple:
        prefetch: 10
        concurrency: 4
        max-concurrency: 8
        acknowledge-mode: manual$code$),
    ('message-ordering-and-partitioning', 1, 'Where Ordering Is Actually Guaranteed', $body$Ordering is a property of a single destination and a single reader, not of the system. A queue preserves the order in which messages were enqueued while exactly one consumer processes it sequentially; the moment two consumers compete, arrival order at each consumer depends on scheduling. Topics preserve per-subscription order but not across subscriptions. Redelivery, retries, and republishing to another destination can also reorder reality. So the honest statement is that ordering is scoped and can be broken by your own recovery paths. Before promising order, identify who must observe it, then reduce the pipeline to the smallest unit that keeps a single writer and a single reader for that unit.$body$, $code$@Bean
DefaultJmsListenerContainerFactory orderedFactory(
        ConnectionFactory connectionFactory) {
    DefaultJmsListenerContainerFactory factory =
        new DefaultJmsListenerContainerFactory();
    factory.setConnectionFactory(connectionFactory);
    factory.setConcurrency("1");
    return factory;
}$code$),
    ('message-ordering-and-partitioning', 2, 'Single Consumers and Message Groups', $body$When order matters for a business entity, serialize that entity. A single consumer per queue is the simplest guarantee: one thread reads in order, processes, and acknowledges, and throughput grows only by making each unit faster. Message groups relax this by routing messages that share a key, such as account id, to the same consumer while other keys proceed in parallel; some brokers support JMSXGroupID for exactly this. The alternative is an application level lock or per-key executor, which trades broker features for custom code and new failure modes. The trade-off to state plainly is throughput versus coordination: strict global order caps parallelism, and any design that claims both usually hides a bottleneck or a correctness gap.$body$, $code$@JmsListener(destination = "account.commands", concurrency = "4")
public void onCommand(Message message) throws JMSException {
    String groupKey = message.getStringProperty("JMSXGroupID");
    workerFor(groupKey).execute(
        () -> ledger.apply(decode(message)));
}$code$),
    ('message-ordering-and-partitioning', 3, 'Partition Keys for Ordered Parallelism', $body$To combine order with parallelism, partition on a stable key such as customer or aggregate identifier, hash it consistently into partitions, and give each partition exactly one consumer at a time. Messages with the same key always land together and are processed in sequence, while different keys proceed concurrently. Watch three pitfalls: a hot key concentrates all traffic in one partition and caps throughput; rebalancing consumers during a deploy can briefly overlap ownership unless you revoke before acquiring; and republishing after a failure sends a key behind newer messages unless consumers can reorder by version. Choose the partition count for peak load with headroom, and record the key selection rule as part of the contract.$body$, $code$// same key -> same partition -> same single consumer
String key = accountId;
int partitions = 64;
int partition = Math.floorMod(key.hashCode(), partitions);
dispatcher.dispatch(partition, event);$code$),
    ('message-idempotency', 1, 'At Least Once Is the Reality', $body$Brokers acknowledge after a consumer confirms, and a crash between processing and acknowledgement makes redelivery unavoidable, so most systems are effectively at least once. Exactly once end to end requires transactions that span the broker, the database, and every downstream system, which few architectures can afford and ordinary messaging does not provide. The practical consequence is that every consumer must assume it may see any message more than once, including after a failover, a rebalance, or a manual replay. Designing consumers for repeat delivery is cheaper than chasing infrastructure guarantees, and it also protects against operator replays during incident recovery. State the assumption in the consumer contract so new handlers inherit it instead of rediscovering it in production.$body$, $code$@Transactional
@JmsListener(destination = "payments.in")
public void onPayment(PaymentMessage message) {
    ledger.record(message.id(), message.amount());
}
// the container acknowledges after commit; a crash before that redelivers$code$),
    ('message-idempotency', 2, 'Deduplication Stores and Retention', $body$A deduplication store records processed message identifiers, and a unique constraint on that identifier turns a duplicate insert into a safe no-op. The strongest variant inserts the identifier in the same transaction that performs the business change, so the two commit or roll back together; a separate transaction risks a crash window between them. Retention matters: the store grows forever unless you expire entries after a window longer than the broker keeps or retries messages. A cache with a time to live is faster but can lose entries on eviction and admit duplicates, so it suits best effort filtering rather than correctness. Prefer the durable unique key approach for money, inventory, and anything a duplicate would corrupt.$body$, $code$@Transactional
public void handle(Event event) {
    int inserted = jdbc.update(
        "INSERT INTO processed_event (id) VALUES (?) "
            + "ON CONFLICT DO NOTHING", event.id());
    if (inserted == 0) {
        return;
    }
    apply(event);
}$code$),
    ('message-idempotency', 3, 'Designing Naturally Idempotent Consumers', $body$The most robust default is to make handlers naturally idempotent, so duplicates cost time but not correctness. Techniques include upserting on a business key, enforcing a state machine that ignores already completed transitions, writing conditional updates with a version or expected status, and recording a processed marker alongside the effect. Idempotency also belongs at the boundary where messages are produced: a stable message id makes detection possible at all. Where the side effect is external, such as sending email or charging a card, keep a local record before the call and query it before retrying. Treat deduplication as part of the consumer, not as an optional layer someone adds after the first duplicate incident.$body$, $code$@Transactional
public void onStockAdjusted(StockAdjusted event) {
    int updated = stock.applyIfNewer(
        event.sku(), event.quantity(), event.version());
    if (updated == 0) {
        log.debug("duplicate or stale event {}", event.id());
    }
}$code$),
    ('poison-messages-and-dlq', 1, 'Recognizing a Poison Message', $body$A poison message is one the consumer can never process successfully, so each delivery ends in the same failure and redelivery repeats it forever. Typical causes are schema changes the consumer does not understand, missing reference data, a bug triggered by a particular value, or a message larger than the handler expects. The symptom is a queue whose depth and redelivery count climb while throughput falls, often with log noise that looks like an application error storm. Brokers expose delivery counts, and JMS flags redelivered messages, so use that metadata to distinguish a transient failure worth retrying from a deterministic one. The rule of thumb: retry only errors you classify as transient, and let everything else leave the main queue quickly.$body$, $code$@JmsListener(destination = "orders.in")
public void onOrder(Message message) {
    // redelivered and still failing: stop looping, let it dead letter
    if (message.getJMSRedelivered()) {
        throw new PermanentFailureException();
    }
    process(message);
}$code$),
    ('poison-messages-and-dlq', 2, 'Dead Letter Topology and Metadata', $body$Dead letter topology gives unprocessable messages a place to wait without blocking healthy traffic. In AMQP you declare a dead letter exchange per queue and bind a dead letter queue to it, so rejected messages are republished with their original destination and failure reason. In JMS the usual pattern is a configured dead letter destination, with broker specific details for how a message qualifies. Preserve the payload plus metadata: message id, original destination, delivery count, exception stack, and the correlation identifier, because replay without context is guesswork. Keep the dead letter queue alarmed and bounded, since it is a queue of unresolved defects rather than an archive. Give each major flow its own dead letter queue so triage stays tractable.$body$, $code$@RabbitListener(queues = "orders.dlq")
public void onDeadLetter(Message failed) {
    Object deaths = failed.getMessageProperties()
        .getHeaders().get("x-death");
    log.error("dead lettered after {}", deaths);
    metrics.counter("orders.dlq.depth").increment();
}$code$),
    ('poison-messages-and-dlq', 3, 'Replay Workflow and DLQ Alerts', $body$Operating a dead letter queue is a workflow, not a checkbox. Triage classifies each message: fix the code and replay, correct the data and replay, or reject it as genuinely invalid and record why. Replay must be idempotent, because the original attempt may have partially succeeded, and it should preserve the original identifier. Alert on growth rate and on messages older than a threshold, not merely on a non-zero depth, or a single stale message will keep a channel noisy. Also alert when the main queue grows but the dead letter queue stays silent, which can mean consumers are stuck in a retry loop instead of failing fast. Without owners and an expiry policy, the dead letter queue becomes a permanent shadow backlog.$body$, $code$@RabbitListener(queues = "orders.dlq")
public void replay(OrderEvent event) {
    if (triage.approved(event.id())) {
        rabbitTemplate.convertAndSend(
            "orders.exchange", "order.created", event);
    }
}$code$),
    ('spring-integration-basics', 1, 'Channels That Decouple Producers', $body$Spring Integration models a flow as messages passing through channels. A DirectChannel invokes subscribers in the sender thread, which preserves a simple call stack and makes failures easy to see. A QueueChannel stores messages until a poller picks them up, adding buffering and decoupling at the cost of background threads and capacity decisions. A publish subscribe channel dispatches a copy to every subscriber. The channel is the seam where you insert throttling, transactions, or persistence, and it deliberately hides collaborators from each other. Choose the synchronous channel by default in request paths, and use buffered channels only when you can describe what happens when the buffer fills and who monitors its depth.$body$, $code$@Bean
IntegrationFlow orders() {
    return IntegrationFlow.from("orders.in")
        .transform(JsonToOrder::convert)
        .channel(c -> c.queue("orders.buffer", 500))
        .handle(orderService, "process")
        .get();
}$code$),
    ('spring-integration-basics', 2, 'Transformers Routers and Gateways', $body$Transformers convert payloads and headers, routers decide the next channel from message content, and gateways present a plain interface to the rest of the application while hiding the messaging inside. This is the vocabulary of enterprise integration patterns made executable, so a flow reads as parse, route, enrich, send rather than as injected boilerplate. Keep transformations pure and test them directly; put decision logic in a router with named destinations rather than in a chain of conditionals. A gateway in both directions prevents messaging types from leaking into business code, which matters when you later replace the transport. Draw the topology explicitly so reviewers can see where a message can be lost or delayed.$body$, $code$@Bean
IntegrationFlow routeByRegion() {
    return IntegrationFlow.from("orders.routed")
        .<Order, String>route(Order::region, mapping -> mapping
            .subFlowMapping("EU", sf -> sf.handle(euService))
            .subFlowMapping("US", sf -> sf.handle(usService)))
        .get();
}$code$),
    ('spring-integration-basics', 3, 'When the DSL Earns Its Place', $body$Hand rolled glue accumulates silently: a scheduler calls a service, which calls an FTP client, which writes to a staging table, and nobody can point to where retries or errors are handled. The Java DSL expresses that flow as a readable IntegrationFlow with declared channels, adapters, and error handling in one place. Adapters cover file, FTP, JMS, HTTP, and database polling so you reuse tested transport code instead of reimplementing it. The cost is an additional abstraction and a learning curve, so it earns its place when a flow has more than two hops, needs routing, or must be inspected and tested as a unit. For a single call with a retry, plain code remains the better choice.$body$, $code$@MessagingGateway
public interface BillingGateway {

    @Gateway(requestChannel = "billing.requests")
    Receipt charge(ChargeCommand command);
}$code$),
    ('apache-camel-for-integration', 1, 'Routes Endpoints and Configuration', $body$A Camel route is a pipeline from a consumer endpoint to processing steps and producer endpoints, described in a RouteBuilder with from and to. Endpoint URIs such as file, jms, http, or direct act as configuration that can be changed without recompiling, which is why Camel is often used for integration layers rather than business logic. In Spring Boot, the camel starter discovers routes and wires components, and property placeholders keep environment specifics out of code. Routes can call beans for domain work, but keep transformation and error handling in the route so the flow is visible in one file, and keep business rules in services where they are unit testable. Treat the URI string as part of the operational contract.$body$, $code$from("jms:queue:orders.in")
    .transacted()
    .bean(OrderValidator.class, "validate")
    .to("jms:queue:orders.valid")
    .to("file:archive/orders?fileName=orders.json");$code$),
    ('apache-camel-for-integration', 2, 'Enterprise Integration Patterns in Camel', $body$Camel supplies the enterprise integration patterns as first class processors: choice for content based routing, split for fan out, aggregate for correlation and grouping, multicast, recipient list, and throttling. Error handling deserves the same care as business logic; a DeadLetterChannel error handler with a redelivery policy retries transient failures and moves exhausted messages to a dead letter endpoint instead of losing them or looping. Idempotent consumers guard against duplicates after redelivery. The pitfall is a route that uses many patterns and no owner: each processor adds state, and aggregators in particular hold memory until completion. State timeouts, completion predicates, and where failures surface, and test each error path deliberately rather than trusting defaults.$body$, $code$from("jms:queue:orders.valid")
    .choice()
        .when(header("priority").isEqualTo("high"))
            .to("jms:queue:orders.express")
        .otherwise()
            .to("jms:queue:orders.standard")
    .end();$code$),
    ('apache-camel-for-integration', 3, 'Testing Routes with Mock Endpoints', $body$Routes deserve their own tests because most integration failures live in wiring, not in beans. The camel test support boots routes with the Spring context, replaces endpoints with mocks so tests do not need a broker, and lets you assert how many messages arrived and with what bodies. That makes fan out, filtering, and dead letter behavior testable in milliseconds. Keep tests focused: one route, one behavior, explicit expected counts, and a timeout so a broken route fails instead of hanging. When a route depends on an external system, stub the endpoint and test your transformation and error handling; verify the real transport separately in an integration environment.$body$, $code$@CamelSpringBootTest
@SpringBootTest
@MockEndpointsAndSkip("jms:queue:orders.*")
class OrderRouteTest {
    @Autowired ProducerTemplate template;
    @EndpointInject("mock:jms:queue:orders.express")
    MockEndpoint express;
    @Test
    void expressGetsHighPriorityMessages() {
        template.sendBodyAndHeader("direct:orders", "{}", "priority", "high");
        express.expectedMessageCount(1);
        express.assertIsSatisfied();
    }
}$code$),
    ('batch-processing-with-spring-batch', 1, 'Jobs Steps and Parameters', $body$Spring Batch separates a Job, the whole run, from Steps, the units that do the work, and persists metadata in a JobRepository so every run is identified by its JobParameters and every step records its outcome. That metadata is what makes a batch auditable and restartable: you can see which parameters produced a failed execution and resume it. Steps can be chunk oriented, a tasklet for a single operation, or a flow of other steps, and listeners attach behavior at job or step boundaries. Parameters must uniquely identify a run; using the current timestamp when you meant the business date makes restarts ambiguous. Design step boundaries so a failure leaves a predictable state and a rerun continues rather than duplicating.$body$, $code$@Bean
Job nightlyJob(JobRepository repository, Step loadStep) {
    return new JobBuilder("nightlyImport", repository)
        .start(loadStep)
        .build();
}

@Bean
JobParameters parameters(String businessDate) {
    return new JobParametersBuilder()
        .addString("businessDate", businessDate)
        .toJobParameters();
}$code$),
    ('batch-processing-with-spring-batch', 2, 'Chunk Processing and Commit Intervals', $body$Chunk oriented steps read one item at a time, optionally transform it, and write the accumulated chunk within a transaction; the commit interval decides how many items form one chunk. A larger interval amortizes transaction cost but increases rollback size and memory, while a smaller one commits more often and resumes closer to the failure point. When the writer fails, the chunk rolls back and is retried according to policy, which is why writers should be transactional or idempotent. An ItemProcessor that returns null filters the item, and readers signal the end of input with null rather than an empty item. The pitfall is doing per item remote calls inside a chunk and turning one transaction into hundreds of network round trips.$body$, $code$@Bean
Step loadStep(JobRepository repository,
              TransactionManager transactionManager) {
    return new StepBuilder("load", repository)
        .<Row, Row>chunk(500, transactionManager)
        .reader(flatFileReader())
        .processor(rowValidator())
        .writer(rowWriter())
        .build();
}$code$),
    ('batch-processing-with-spring-batch', 3, 'Restart Skip and Partition', $body$Restartability comes from persisted execution context: after a failure, a restarted job resumes at the last committed chunk rather than reprocessing everything, unless you disable restart or a step is not restartable. Skip and retry limits let you tolerate occasional bad records without failing the job, but each skipped record should be logged and observable. For scale, partitioning splits a step into independent worker executions coordinated by a partition handler, and remote partitioning distributes them across processes. Partitioning needs a sensible split key, evenly sized ranges, and a working directory or database per worker to avoid collisions. Never partition a step whose writer assumes a single writer, such as one that rewrites a shared file.$body$, $code$@Bean
Step partitionStep(JobRepository repository,
                   PartitionHandler handler) {
    return new StepBuilder("loadPartitioned", repository)
        .partitioner("load", columnRangePartitioner())
        .partitionHandler(handler)
        .build();
}$code$),
    ('scheduling-and-quartz', 1, 'Cron Semantics and Time Zones', $body$Quartz cron expressions have six or seven fields, seconds first, then minutes, hours, day of month, month, day of week, and optionally year, so the familiar five field Unix form does not transfer unchanged. Day of month and day of week interact with an OR rule unless you mask one field, which surprises teams porting expressions. Always state the scheduler time zone explicitly, because a job written for one region will run at a different local time after a migration or during daylight saving transitions. Test the trigger by asking when the next several fire times are, not by reading the expression. For business schedules, prefer a cron that expresses intent over one that merely matches a wall clock time on one laptop.$body$, $code$@Bean
Trigger nightlyTrigger() {
    return TriggerBuilder.newTrigger()
        .withIdentity("nightly")
        .withSchedule(CronScheduleBuilder
            .cronSchedule("0 0 2 * * ?")
            .inTimeZone(TimeZone.getTimeZone("Europe/Sofia")))
        .build();
}$code$),
    ('scheduling-and-quartz', 2, 'Misfire Policies That Match Intent', $body$Misfires happen when the scheduler cannot fire on time, for example because the previous execution still runs or the process was down; the misfire instruction decides what happens next. Firing immediately recovers late work but can cause a burst when several misfires accumulate, while doing nothing lets the schedule continue cleanly and skips the missed run. Annotate stateful jobs that must not overlap with disallow concurrent execution so a late trigger waits instead of starting a second execution against shared data. Keep jobs short and idempotent, because long jobs turn every restart into a misfire decision. Write the chosen policy down next to the schedule, since defaults differ from what an operator expects during an incident.$body$, $code$@Bean
Trigger reportTrigger() {
    return TriggerBuilder.newTrigger()
        .forJob("report")
        .withSchedule(CronScheduleBuilder
            .cronSchedule("0 0 6 * * ?")
            .withMisfireHandlingInstructionDoNothing())
        .build();
}$code$),
    ('scheduling-and-quartz', 3, 'Clustered Scheduling Without Duplicate Runs', $body$Running scheduled work on several instances invites duplicate execution, so use the clustered JDBC job store, which coordinates triggers through database row locks and lets only one node fire each trigger. All nodes must share the same database and be time synchronized, and manual triggers through the API bypass that coordination unless they also go through the scheduler. Alternatively, elect a single scheduler leader or use platform scheduling with one guaranteed owner, and make the job itself idempotent as a second line of defense. Alert when no node fires for longer than the interval, because a cluster split could leave the trigger unowned. Never rely on the scheduler alone for correctness: the job must tolerate a duplicate run.$body$, $code$spring:
  quartz:
    job-store-type: jdbc
    jdbc:
      initialize-schema: never
    properties:
      org.quartz.scheduler.instanceId: AUTO
      org.quartz.jobStore.isClustered: true
      org.quartz.jobStore.clusterCheckinInterval: 10000$code$),
    ('file-and-ftp-integration', 1, 'Polling Inbound Files and Filters', $body$Inbound file integration polls a directory on a fixed interval and emits one message per file, then moves or deletes the file so it is not read again. Filters decide what qualifies: name patterns for expected feeds, age thresholds that skip files still being written, and accept once filters that prevent duplicates across restarts. Prefer a persistent filter backed by a database or cache for anything that matters, because an in-memory filter forgets its state on redeploy and reingests everything. When files arrive over FTP, the same ideas apply to the remote directory, with a separate copy step so a partial upload is never parsed. Polling interval, filter, and post processing action together define the ingestion contract.$body$, $code$@Bean
IntegrationFlow csvInbound() {
    return IntegrationFlow
        .from(Files.inboundAdapter(new File("/data/inbox"))
                .filter(new AcceptOnceFileListFilter<>()),
            e -> e.poller(Pollers.fixedDelay(5000)))
        .handle(ImportService.class, "importCsv")
        .get();
}$code$),
    ('file-and-ftp-integration', 2, 'Detecting Partial Files Safely', $body$The classic failure is reading a file while a producer is still writing it, which yields a truncated parse and a confusing error. Require producers to write to a temporary name and rename into the pickup directory, since rename is atomic on the same filesystem; only process names that match the final pattern. When the producer cannot cooperate, detect partial files with a stability check, such as reading size twice with a delay, or an expected checksum or end marker. Whatever the mechanism, ingestion should be idempotent: compute a hash or use the feed identity plus business date as the deduplication key, and record what was loaded. A file that parses but contains invalid rows needs a defined policy for skipping or rejecting.$body$, $code$// producers write orders-123.csv.tmp, then rename into place
Path tmp = inbox.resolve("orders-123.csv.tmp");
Files.write(tmp, payload);
Files.move(tmp, inbox.resolve("orders-123.csv"),
    StandardCopyOption.ATOMIC_MOVE);$code$),
    ('file-and-ftp-integration', 3, 'Archival and Retention Conventions', $body$After a file is processed it should leave the pickup directory, or the next poll will consider it again. Common conventions move processed files to a dated processed folder, move permanently failing files to an error folder with the failure reason, and archive originals for audit with a retention period. Keep names and folder structure predictable so operators can find the source of any loaded record months later. Track file level metadata, such as arrival time, size, checksum, and row counts, because that is what you need when someone asks whether the overnight feed arrived completely. Deleting quickly saves disk but destroys evidence, so set retention based on audit and replay needs rather than convenience.$body$, $code$@Bean
IntegrationFlow archiveFlow() {
    return IntegrationFlow.from("files.processed")
        .handle(Files.outboundAdapter("/data/archive")
            .autoCreateDirectory(true)
            .fileExistsMode(FileExistsMode.REPLACE))
        .get();
}$code$),
    ('soap-and-legacy-integration', 1, 'WSDL-First Clients and Versioning', $body$A WSDL is a complete contract: operations, messages, bindings, and often the schema. Generate the client from it so types and operations match exactly, and regenerate when it changes instead of hand editing generated code. This is the opposite of code first habits, and it is what legacy providers expect. Version the WSDL artifact, record which service version a consumer uses, and test against a pinned copy so a provider change is detected deliberately rather than at runtime. When the WSDL is large or disorganized, wrap the generated client behind your own interface and translate into your domain models. Keep the generated surface at the edge, because its naming and structure rarely suit application code.$body$, $code$class OrderClient extends WebServiceGatewaySupport {

    OrderResponse submit(OrderRequest request) {
        return (OrderResponse) getWebServiceTemplate()
            .marshalSendAndReceive(
                "https://legacy.example.com/OrderService",
                request);
    }
}$code$),
    ('soap-and-legacy-integration', 2, 'SOAP Faults and Transport Errors', $body$SOAP faults are application level errors carried in the envelope, and they arrive as exceptions in JAX-WS clients, so distinguish them from transport failures such as connection resets and HTTP 500 responses. A fault may include a code and detail structure that carries the business reason, which is what you should map and log; retrying a business fault is pointless while retrying a transport failure may help. Handlers and policies add headers for security, logging, or correlation without touching generated code. Because SOAP stacks vary, test the specific provider in a realistic environment, including timeouts and authentication, rather than assuming a different stack behaves the same. Always cap timeouts; a legacy service with no timeout can hang a worker thread for minutes.$body$, $code$try {
    client.submit(request);
} catch (SoapFaultClientException fault) {
    log.warn("legacy rejected order: {}", fault.getMessage());
    throw new OrderRejectedException(request.id());
} catch (WebServiceIOException transport) {
    throw new TransientIntegrationException(transport);
}$code$),
    ('soap-and-legacy-integration', 3, 'Wrapping Legacy Services Behind APIs', $body$Wrapping a legacy SOAP service behind a modern API is often the cheapest path to decoupling. Build a facade that speaks your REST or messaging contract on the outside and SOAP on the inside, translating models and errors at the boundary, so clients stop depending on WSDL quirks and generated types. The wrapper can add timeouts, retries, caching, and observability the legacy stack cannot provide. Beware of hiding essential semantics: if the legacy service requires a session, has quirky ordering rules, or exposes synchronous only operations, the wrapper must surface that reality rather than pretend it is a simple resource. Own the translation tests, because that mapping is now the contract your consumers rely on.$body$, $code$@RestController
class OrderFacade {
    private final LegacyOrderClient legacy;

    @PostMapping("/orders")
    OrderView place(@RequestBody PlaceOrder body) {
        OrderResponse response = legacy.submit(toSoap(body));
        return toView(response);
    }
}$code$),
    ('webhooks-outbound-and-inbound', 1, 'Outbound Delivery with Retries', $body$Outbound webhooks are push notifications over HTTP, and their delivery is at least once: a receiver may time out while still processing, or an acknowledgement may be lost, so duplicate deliveries are normal. Retry failed deliveries with exponential backoff and jitter, cap attempts, and keep a per subscriber queue so one slow endpoint does not starve others. Treat each delivery as a small job with a recorded outcome so operators can see what is pending, and expose a way to replay. Use short connection and read timeouts, because a hanging endpoint otherwise consumes your worker pool. Document the retry schedule and the maximum age of a delivery, since receivers plan their idempotency window around that number.$body$, $code$for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    if (deliver(subscription, payload)) return;
    long backoff = (1L << attempt) * 1000L;
    long jitter = ThreadLocalRandom.current().nextLong(1000);
    sleep(Duration.ofMillis(backoff + jitter));
}
deadLetter.publish(subscription, payload);$code$),
    ('webhooks-outbound-and-inbound', 2, 'Signing Payloads and Replay Windows', $body$A signature lets the receiver verify that a payload came from you and was not altered in transit. The common scheme is an HMAC over the raw request body plus a timestamp header, computed with a shared secret unique to the subscriber, and compared in constant time by the receiver. Include the timestamp inside the signed content and reject requests outside a short replay window, which stops captured payloads from being replayed later. Secrets must be rotatable, so support two active secrets during rotation and document the header format precisely. Never sign a canonicalized or re-serialized body unless you specify the exact rules, because whitespace and ordering differences break verification in ways that are painful to debug.$body$, $code$String timestamp = Long.toString(Instant.now().getEpochSecond());
String signed = timestamp + "." + body;
String signature = HexFormat.of().formatHex(
    hmac("HmacSHA256", secret).doFinal(signed.getBytes(UTF_8)));
headers.set("X-Timestamp", timestamp);
headers.set("X-Signature", signature);$code$),
    ('webhooks-outbound-and-inbound', 3, 'Receiving Webhooks Idempotently', $body$Inbound webhooks should be verified, acknowledged quickly, and processed asynchronously. Check the signature first, reject requests that fail or fall outside the replay window, then return a success response within the provider timeout while publishing the event to a queue for real work. Deduplicate on the provider event identifier, because retries and provider side at least once semantics guarantee repeats, and store the identifier in the same transaction as the effect. Model each event type explicitly and ignore unknown ones gracefully so a provider adding a field does not break parsing. Never trust webhook content for authorization decisions, since the payload describes what a third party claims happened. Track received, rejected, and duplicate counts so signature mistakes are visible.$body$, $code$@PostMapping("/webhooks/payments")
ResponseEntity<Void> receive(@RequestBody byte[] body,
        @RequestHeader("X-Signature") String signature) {
    if (!verify(body, signature)) {
        return ResponseEntity.status(401).build();
    }
    events.publish(parse(body));
    return ResponseEntity.accepted().build();
}$code$),
    ('email-and-notification-pipelines', 1, 'Templates That Render Safely', $body$Notification content is code that renders data into templates for email, SMS, or chat, so treat templates as versioned artifacts with tests. Use a real template engine for escaping and layouts, and make the difference between HTML and plain text explicit rather than deriving one from the other. Localize per recipient, including number and date formats, and keep a preview test that renders every template with representative data so a broken placeholder fails in continuous integration rather than in a customer inbox. The pitfall is building bodies with string concatenation, which mixes data and markup and makes escaping an afterthought. A template change is a production change: review it, render it, and be able to roll it back.$body$, $code$Context context = new Context(Locale.forLanguageTag(user.locale()));
context.setVariable("name", user.firstName());
context.setVariable("orderId", order.id());

String html = templateEngine.process("order-confirmed", context);
mailSender.send(buildMessage(user.email(), html));$code$),
    ('email-and-notification-pipelines', 2, 'Delivery Guarantees and Honest Promises', $body$Application code hands email to a relay and typically learns only that the server accepted it, not that it was delivered, so treat delivery as best effort with retries. Send asynchronously through a queue or outbox so a slow mail server never blocks a user request, and record the attempt and its outcome so failures can be retried or explained. Because resending after a timeout can duplicate a message, deduplicate on a notification identity rather than assuming the transport is exactly once. For anything important, pair the mail with an in application inbox or status page, since email can be delayed, filtered, or lost silently. Do not promise delivery in product language when the pipeline cannot verify it.$body$, $code$@Transactional
public void enqueueOrderConfirmation(Order order) {
    outbox.save(new OutboxEntry(
        "order-confirmed", order.id(), order.customerEmail()));
}

@Scheduled(fixedDelay = 5000)
public void flushOutbox() {
    outbox.findUnsent().forEach(this::sendAndMark);
}$code$),
    ('email-and-notification-pipelines', 3, 'Bounces Suppression and Volume Control', $body$Mail servers report bounces after the fact: hard bounces mean the address is permanently invalid and should be suppressed immediately, while soft bounces are temporary and deserve a limited number of retries over days. Maintain a suppression list, honor unsubscribe requests promptly, and record the reason so re subscription is deliberate. Control volume per recipient with preferences, deduplication of identical notifications, and quiet hours, because several systems sending independently produces spam even when each message is legitimate. Rate limit per domain and monitor complaint rates, since reputation damage is slow to repair. The design rule is that every notification has an owner, a purpose, and a way for the recipient to stop it.$body$, $code$public void onBounce(BounceNotification bounce) {
    if (bounce.isHard()) {
        suppression.suppress(bounce.email(), bounce.reason());
    } else {
        suppression.incrementSoft(bounce.email());
    }
}$code$),
    ('integration-testing-across-systems', 1, 'End-to-End Flows with Containers', $body$End-to-end integration tests need the real wire protocols, so run the broker and database in containers rather than mocking their APIs. Testcontainers starts RabbitMQ, ActiveMQ, or PostgreSQL per test class, and Spring Boot service connections wire the client properties automatically; queues, exchanges, and schemas are created by the test. This catches the failures mocks cannot: serialization differences, transaction boundaries, acknowledgement behavior, and timeouts. Keep the number of full flow tests small and focused on the seams between systems, and cover detailed logic with faster tests. Pin image versions so behavior changes are deliberate, and allow more generous timeouts than unit tests because container startup dominates the runtime.$body$, $code$@Testcontainers
@SpringBootTest
class OrderFlowIT {

    @Container
    @ServiceConnection
    static RabbitMQContainer broker =
        new RabbitMQContainer("rabbitmq:4.0-management");

    @Test
    void failingOrderReachesDeadLetterQueue() { }
}$code$),
    ('integration-testing-across-systems', 2, 'Contract Checks Between Systems', $body$Contract checks catch integration breakage before environments meet. Consumer driven contracts, generated from the consumer side and verified against the provider, express exactly which fields and behaviors a consumer depends on, so a provider change that breaks someone fails a build rather than production. Message schemas deserve the same treatment: check compatibility rules for new fields, renames, and required additions, and keep a shared registry or repository of schemas. Run these checks in both pipelines so a provider cannot merge a change that no consumer has approved. Contracts do not replace a small number of end to end tests, because serialization, transport, and timing issues still appear only when real systems talk.$body$, $code$Contract.make {
    request {
        method POST()
        url '/orders'
    }
    response {
        status CREATED()
        body(id: $(consumer(regex('[0-9]+')), producer('42')))
    }
}$code$),
    ('integration-testing-across-systems', 3, 'Test Data Lifecycle Hygiene', $body$Integration tests share state, and shared state creates flakiness. Give each test its own namespace: unique queue names or virtual hosts, a dedicated schema or database, and per test tenants, then clean up or discard them afterwards so reruns start clean. Seed only the data the flow needs, with stable identifiers, and avoid depending on records left by other tests or by a previous run. Make async assertions wait for a condition with a bounded timeout rather than sleeping a fixed time, and collect the messages you expect from a subscription before triggering the flow so nothing is missed. When a test fails, preserve enough state, such as logs and message dumps, to diagnose without rerunning blind.$body$, $code$@BeforeEach
void prepareIsolatedNamespace() {
    queue = "test.orders." + UUID.randomUUID();
    broker.declareQueue(queue);
}

@AfterEach
void releaseNamespace() {
    broker.deleteQueue(queue);
    jdbc.update("DELETE FROM processed_event WHERE id LIKE ?", prefix);
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
    'messaging-vs-http-integration', 'jms-fundamentals',
    'rabbitmq-with-spring-amqp', 'message-ordering-and-partitioning',
    'message-idempotency', 'poison-messages-and-dlq',
    'spring-integration-basics', 'apache-camel-for-integration',
    'batch-processing-with-spring-batch', 'scheduling-and-quartz',
    'file-and-ftp-integration', 'soap-and-legacy-integration',
    'webhooks-outbound-and-inbound', 'email-and-notification-pipelines',
    'integration-testing-across-systems'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
