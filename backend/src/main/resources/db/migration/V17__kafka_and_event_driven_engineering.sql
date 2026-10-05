-- V17 — Kafka and event-driven engineering.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('kafka-architecture-brokers-topics', 'Kafka Architecture: Brokers, Topics, Partitions', 'Understand brokers, topics, partitions, and in-sync replicas before they surprise you in production.', 'Mid', 28, true, 1),
    ('kafka-producers-and-acks', 'Kafka Producers, Acks, and Delivery Guarantees', 'Configure acknowledgments, retries, batching, and idempotence so producers deliver what you promise.', 'Mid', 30, true, 1),
    ('kafka-consumers-and-offsets', 'Kafka Consumers: Poll Loops and Offsets', 'Run poll loops that respect the broker contract and choose commit strategies that match processing semantics.', 'Mid', 30, true, 1),
    ('kafka-consumer-groups-and-rebalancing', 'Consumer Groups and Cooperative Rebalancing', 'Understand group coordination and choose assignment strategies that avoid disruptive stop-the-world rebalances.', 'Mid', 32, true, 1),
    ('kafka-partitioning-strategy', 'Choosing Keys and Partitioning Strategy', 'Pick keys that preserve required ordering without creating hot partitions or skewed brokers.', 'Senior', 36, true, 1),
    ('kafka-delivery-semantics', 'Delivery Semantics End to End', 'Compare at-most-once, at-least-once, and exactly-once processing and what each one really guarantees.', 'Senior', 36, true, 1),
    ('kafka-exactly-once-processing', 'Exactly-Once Processing with Transactions', 'Wire the transactional read-process-write loop and understand its real limits and costs.', 'Senior', 42, true, 1),
    ('kafka-schema-evolution', 'Schema Evolution with a Registry', 'Version Avro or Protobuf schemas safely and roll changes out in an order consumers can follow.', 'Senior', 38, true, 1),
    ('kafka-retries-and-dead-letters', 'Retries, Backoff, and Dead-Letter Topics', 'Design retry topologies and a dead-letter procedure that can actually replay failed events.', 'Senior', 40, true, 1),
    ('kafka-transactions', 'Kafka Transactions in Practice', 'Use the transactional producer API and read_committed consumers without breaking the guarantees.', 'Senior', 40, true, 1),
    ('kafka-streams-essentials', 'Kafka Streams: Streams, Tables, State', 'Build stateful stream processing with KStream, KTable, and fault-tolerant state stores.', 'Senior', 42, true, 1),
    ('kafka-connect-essentials', 'Kafka Connect: Managed Data Pipelines', 'Run source and sink connectors with clear ownership, tested transforms, and monitored failure paths.', 'Senior', 38, true, 1),
    ('kafka-testing-strategies', 'Testing Kafka Pipelines and Contracts', 'Choose brokers, Testcontainers, and contract checks that catch integration failures before production.', 'Lead', 40, true, 1),
    ('event-sourcing-fundamentals', 'Event Sourcing Fundamentals', 'Use append-only event logs as the source of truth and know when the pattern is not worth its cost.', 'Lead', 44, true, 1),
    ('cqrs-fundamentals', 'CQRS Fundamentals', 'Separate command and query paths, derive read models from events, and set consistency expectations explicitly.', 'Lead', 42, true, 1),
    ('event-schema-governance', 'Event Schema Governance', 'Establish naming, ownership, versioning, and registry practices that keep event contracts trustworthy.', 'Lead', 40, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('kafka-architecture-brokers-topics', 1, 'A topic is a partitioned log', $body$A Kafka topic is a named log split into partitions, and each partition is an append-only sequence of records with monotonically increasing offsets. Partitions are the unit of parallelism: consumers in a group distribute partitions between themselves, and ordering is guaranteed only within a single partition, never across a topic. Producers choose a partition by key or let the client balance records. Choosing partition counts is a capacity decision that is hard to reverse: adding partitions later changes key placement, while removing partitions is not supported. Start from required consumer parallelism and target throughput per partition.$body$, $code$bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --create --topic orders \
  --partitions 6 --replication-factor 3
bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --topic orders$code$),
    ('kafka-architecture-brokers-topics', 2, 'Replication factor and in-sync replicas', $body$Every partition has one leader and a set of follower replicas; the replication factor is how many copies exist. A record counts as committed when all replicas in the in-sync replica set (ISR) have applied it, which is why acks=all reports success only after ISR acknowledgment. If the ISR shrinks below min.insync.replicas, writes with acks=all are rejected rather than silently losing durability. Under-replicated partitions signal degraded safety; a single-replica partition offers no failover. A practical production baseline is replication factor three with min.insync.replicas of two, accepting that rare multi-broker failures interrupt writes instead of losing acknowledged data.$body$, $code$# topic-level durability settings
min.insync.replicas=2

# producer waits for all in-sync replicas
acks=all$code$),
    ('kafka-architecture-brokers-topics', 3, 'Failover moves leadership not data', $body$Brokers register with the controller, which tracks partition leadership and ISR membership. When a leader fails, the controller promotes an in-sync follower, and clients refresh metadata to route requests to the new leader. Because leaders are chosen from the ISR, committed records survive as long as at least one in-sync replica remains alive. Unclean leader election breaks that promise and can discard data, so keep it disabled in production. Clients only need bootstrap servers to discover the cluster. When investigating incidents, start with offline and under-replicated partition counts, then check controller health and disk usage.$body$, $code$bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --unavailable-partitions
bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --under-replicated-partitions
bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --topic orders | grep -E "Leader|Isr"$code$),
    ('kafka-producers-and-acks', 1, 'Acks trade latency for durability', $body$The acks setting controls how many acknowledgments the producer requires before treating a send as complete. With acks=0 the producer does not wait and can lose records without knowing; acks=1 waits only for the leader write, so a leader failure before replication can still lose an acknowledged record; acks=all waits for the full in-sync replica set and is required when idempotence is enabled. Retries cover transient errors, and delivery.timeout.ms, two minutes by default, bounds the total time including retries. The common production pitfall is leaving acks=1 on data that someone believes is durable. Default to acks=all for business events.$body$, $code$props.put(ProducerConfig.ACKS_CONFIG, "all");
props.put(ProducerConfig.RETRIES_CONFIG, 10);
props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 120_000);
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);

ProducerRecord<String, String> record =
    new ProducerRecord<>("orders", orderId, json);
producer.send(record).get();$code$),
    ('kafka-producers-and-acks', 2, 'Batching, linger, and throughput', $body$Producers accumulate records per partition into batches; batch.size bounds a batch in bytes and linger.ms adds a small delay so more records can join. Current clients default linger.ms to five milliseconds, a deliberate latency for throughput trade. Compression applies to whole batches, so larger batches usually compress better and reduce broker load. Increasing linger raises end-to-end latency for low-volume traffic, because even a single record waits. Backpressure appears as blocking sends when the record buffer fills, controlled by buffer.memory and max.block.ms. Tune with measurement, not by reflex: check average batch size and request rate before changing defaults.$body$, $code$props.put(ProducerConfig.BATCH_SIZE_CONFIG, 65_536);
props.put(ProducerConfig.LINGER_MS_CONFIG, 20);
props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "lz4");
// send() returns a future that completes on acknowledgment
producer.send(record, (metadata, error) -> {
    if (error != null) log.warn("send failed", error);
});$code$),
    ('kafka-producers-and-acks', 3, 'The idempotent producer avoids duplicates', $body$When enable.idempotence is true, the broker assigns the producer an id and deduplicates records by sequence number, so retries cannot create duplicates inside one producer session. The client enables idempotence by default when configuration does not conflict; it requires acks=all, retries greater than zero, and at most five in-flight requests per connection, with ordering preserved for any allowed value. This fixes the classic retry duplication and reordering problems, but it stops at the broker: consumers can still see a record twice when a crash happens between processing and committing. Treat idempotence as the default and pair it with idempotent consumers or transactions when duplicates are unacceptable.$body$, $code$props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
// requires:
//   acks=all, retries > 0
//   max.in.flight.requests.per.connection <= 5
props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);$code$),
    ('kafka-consumers-and-offsets', 1, 'The poll loop is the liveness contract', $body$A consumer must keep calling poll(); the broker treats a member that does not poll within max.poll.interval.ms, five minutes by default, as failed and reassigns its partitions. Long processing inside the loop is therefore a common outage trigger, because records are processed slower than the timeout while heartbeats continue on a background thread. Bound work per poll with max.poll.records, five hundred by default, or hand records to a worker pool while pausing partitions. Also close consumers on shutdown so the group rebalances immediately instead of waiting for a session timeout. The loop is the consumer liveness contract, not overhead to hide.$body$, $code$while (running) {
    ConsumerRecords<String, String> records =
        consumer.poll(Duration.ofMillis(200));
    for (ConsumerRecord<String, String> record : records) {
        process(record);
    }
}
consumer.close();$code$),
    ('kafka-consumers-and-offsets', 2, 'Auto commit versus manual commit', $body$With enable.auto.commit=true the client commits the last polled offsets in the background every auto.commit.interval.ms, five seconds by default. That can acknowledge records that were never processed when the process dies mid-batch. Manual commitSync or commitAsync after successful processing gives at-least-once behavior: a crash before commit replays the batch, so effects must be idempotent. commitAsync is faster but does not retry on failure and callbacks can complete out of order; commitSync blocks and retries. A common pattern is synchronous commits at batch boundaries using the record offset plus one.$body$, $code$for (ConsumerRecord<String, String> record : records) {
    process(record);
    offsets.put(
        new TopicPartition(record.topic(), record.partition()),
        new OffsetAndMetadata(record.offset() + 1));
}
consumer.commitSync(offsets);$code$),
    ('kafka-consumers-and-offsets', 3, 'Where offsets live and resets apply', $body$Committed offsets are stored for each group in the internal __consumer_offsets topic, which is why group ids are stateful: reusing a group id resumes wherever the previous incarnation stopped. auto.offset.reset applies only when no committed offset exists, and its default is latest, meaning a brand-new group silently skips existing messages. That default turns a typo in a group id into missing data. Set earliest deliberately during development and replays, use none when missing offsets should fail loudly, and treat group ids as versioned identifiers owned by one application. Renaming a consumer group is a data-movement decision, not a refactor.$body$, $code$props.put(ConsumerConfig.GROUP_ID_CONFIG, "orders-fulfillment-v2");
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);

bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group orders-fulfillment-v2$code$),
    ('kafka-consumer-groups-and-rebalancing', 1, 'Partition ownership inside one group', $body$Within a consumer group, the coordinator assigns every partition of the subscribed topics to exactly one member, so consumers scale horizontally up to the partition count and extra members sit idle. Members can be identified by group.instance.id when static membership is used, which avoids reassignment churn during restarts. The default assignment strategy list pairs range assignment with cooperative sticky assignment, so clients can migrate without a coordinated flag day. Inspect membership with kafka-consumer-groups.sh --describe to see which member owns which partition, lag per partition, and whether the group is stable.$body$, $code$props.put(ConsumerConfig.GROUP_ID_CONFIG, "orders-fulfillment-v2");
props.put(ConsumerConfig.GROUP_INSTANCE_ID_CONFIG, "orders-1");
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG,
    "org.apache.kafka.clients.consumer.CooperativeStickyAssignor");
// inspect ownership from the command line:
// kafka-consumer-groups.sh --describe --group orders-fulfillment-v2$code$),
    ('kafka-consumer-groups-and-rebalancing', 2, 'Cooperative rebalancing avoids mass revocation', $body$Older eager rebalancing revokes every partition from every member, pauses the group, and reassigns from scratch, producing a visible processing gap. Cooperative rebalancing revokes only partitions that actually move, letting consumers keep processing what they retain during the transition. The cooperative sticky assignor implements this while preserving assignment balance. Migration is incremental: add the cooperative assignor to the strategy list during a rolling restart rather than switching everyone at once. Rebalances still pause moved partitions, so the goal is fewer, smaller disruptions, not zero disruption. The newer consumer group protocol goes further with fully incremental, broker-driven rebalances.$body$, $code$// move to cooperative rebalancing with a rolling restart
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG,
    "org.apache.kafka.clients.consumer.RangeAssignor,"
  + "org.apache.kafka.clients.consumer.CooperativeStickyAssignor");

// Java 11+ allows class literals:
// List.of(RangeAssignor.class, CooperativeStickyAssignor.class)$code$),
    ('kafka-consumer-groups-and-rebalancing', 3, 'Designing applications around rebalances', $body$Rebalances trigger when members join or leave, when a session times out, or when a member exceeds the poll interval. Deploys therefore cause them by design: shut down consumers cleanly with close(), which leaves the group immediately, and expect a brief pause as partitions move. Repeated rebalances without a deploy usually mean one consumer is stuck processing too long or heartbeating too slowly. Persist per-partition state outside the consumer, commit before partitions are revoked, and make processing idempotent so redelivery after a move is safe. Rebalance listeners exist precisely for such cleanup work.$body$, $code$consumer.subscribe(List.of("orders"), new ConsumerRebalanceListener() {
    public void onPartitionsRevoked(Collection<TopicPartition> parts) {
        consumer.commitSync();  // commit before losing ownership
    }
    public void onPartitionsAssigned(Collection<TopicPartition> parts) {
        log.info("assigned {}", parts);
    }
});$code$),
    ('kafka-partitioning-strategy', 1, 'Keys define ordering and placement', $body$The default partitioner hashes a record key and maps it to a partition, so all records sharing a key land in the same partition and are ordered relative to each other. Nothing orders records across partitions, which is exactly why key choice is a correctness decision: order by the entity whose events must be sequential, such as order id or account id, not by convenience. Records without keys are spread across partitions for load balance, but they lose ordering. Distinct key counts matter too: too few keys concentrate load, while unbounded keys with uneven activity still skew. Document the ordering contract for every topic.$body$, $code$// key: order id, so events for one order stay ordered
ProducerRecord<String, String> record =
    new ProducerRecord<>("orders", order.id(), json);

// partitions are chosen by hash(key) % numPartitions
producer.send(record);$code$),
    ('kafka-partitioning-strategy', 2, 'Detecting and mitigating hot partitions', $body$Even distribution of keys does not guarantee even distribution of bytes: one celebrity account or one tenant can dominate traffic and pin a single partition to a broker core. Watch per-partition byte and record rates, not just topic totals, and alert on broker resource skew. Mitigations include bucketing a hot key into sub-keys when per-sub-key ordering suffices, splitting the topic by domain, or increasing partitions so unrelated keys spread further. Never randomize a key that carries an ordering requirement. Capacity planning per partition, with headroom, beats average-based planning that hides the tail.$body$, $code$// spread a hot key while keeping coarse ordering
int bucket = ThreadLocalRandom.current().nextInt(8);
String key = accountId + "#" + bucket;
producer.send(new ProducerRecord<>("account-events", key, event));
// consumers merge buckets only when account-level order is not required$code$),
    ('kafka-partitioning-strategy', 3, 'Changing partition counts safely', $body$You can increase a topic partition count, but the hash-to-partition mapping changes for many keys, so per-key ordering across the change and stateful consumers that assume stable placement are at risk. You cannot decrease partitions at all. When ordering matters, prefer creating a new topic with the right partition count and migrating producers and consumers deliberately. If you must alter a topic in place, coordinate with every stateful consumer and expect temporary skew while keys rebalance. Choose generous partition counts early, because partition counts are far cheaper to overprovision than to fix under load.$body$, $code$bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --alter --topic orders --partitions 12
# partition count can be increased but never reduced;
# key-to-partition mapping changes for many keys
bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --topic orders | head -3$code$),
    ('kafka-delivery-semantics', 1, 'Publishing and consuming are separate problems', $body$Delivery semantics decompose into two questions: can a published record be lost, and can a consumed record be processed twice. At most once means records may be lost but are never redelivered, typical when committing offsets before processing or when a producer ignores failures. At least once means records are never lost but may be redelivered, typical when committing offsets after processing and retrying sends. Exactly once means each record is processed once and only once, and it requires cooperation between producer, broker, and consumer. Read guarantees carefully: a claim about delivery is not automatically a claim about your database writes.$body$, $code$// at most once:  commit offsets before processing
// at least once: commit offsets after processing
// exactly once:  read_committed + transactional producer
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
props.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");$code$),
    ('kafka-delivery-semantics', 2, 'At-least-once is the pragmatic default', $body$At least once is the natural result of acknowledging work only after it succeeds, and it is the right default for most pipelines because losing business events is usually worse than replaying them. Duplicates arise from crashes between processing and commit, producer retries without idempotence, and rebalances that replay uncommitted batches. The countermeasure is not tighter coordination but idempotent side effects: upserts keyed by event id, unique constraints, or processed-event tables. Once consumers are idempotent, replay stops being scary and becomes an operational strength. Document which topics are replay-safe and which are not.$body$, $code$CREATE TABLE processed_event (
    event_id UUID PRIMARY KEY,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO processed_event (event_id) VALUES (:eventId)
ON CONFLICT (event_id) DO NOTHING;
-- apply the effect only when this insert inserted one row$code$),
    ('kafka-delivery-semantics', 3, 'Exactly once requires coordinated machinery', $body$Exactly once in Kafka is built from the idempotent producer plus transactions that atomically commit produced records together with consumed offsets. Consumers read with isolation.level=read_committed so aborted writes stay invisible. The guarantee covers Kafka-to-Kafka pipelines: atomicity does not extend to an external database or an HTTP call inside the same transaction, which still needs its own idempotence or an outbox. Transactions add latency, coordinator load, and fencing complexity, and they need a replicated transaction log. Use them where duplicate processing genuinely breaks something, not by default.$body$, $code$// transactional producer plus read_committed consumer
props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "orders-tx-1");
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
consumerProps.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");
consumerProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);$code$),
    ('kafka-exactly-once-processing', 1, 'The read-process-write transaction shape', $body$Exactly-once processing of a consume-transform-produce step uses one transactional producer per consumer instance. The producer calls initTransactions once, then beginTransaction; records are produced and the consumer offsets for the processed records are attached with sendOffsetsToTransaction using the consumer group metadata, all inside the same transaction; commitTransaction makes both visible together, and abortTransaction discards both. Fencing is a feature: starting another producer with the same transactional.id aborts the previous instance and forces it to stop, preventing two writers from committing interleaved transactions. Some errors are fatal and demand a restart, not a retry.$body$, $code$producer.initTransactions();
while (running) {
    ConsumerRecords<String, String> records =
        consumer.poll(Duration.ofMillis(500));
    producer.beginTransaction();
    for (ConsumerRecord<String, String> r : records) {
        producer.send(new ProducerRecord<>("outbox", r.key(), transform(r.value())));
    }
    producer.sendOffsetsToTransaction(currentOffsets(records), consumer.groupMetadata());
    producer.commitTransaction();
}$code$),
    ('kafka-exactly-once-processing', 2, 'What the guarantee covers and omits', $body$The transaction makes Kafka records and consumer offsets atomic: readers with read_committed see the produced records only after commit, and an aborted attempt leaves neither outputs nor committed offsets. That guarantee ends at the Kafka boundary. Writing to a relational database or calling a remote service inside the loop is not covered, so those effects need idempotency keys, conditional writes, a transactional outbox, or compensation. The guarantee also does not prevent duplicates that another non-transactional producer writes to the same topic. State clearly in design documents where the exactly-once guarantee stops and whose responsibility the remainder is.$body$, $code$try {
    // DB write and Kafka produce are not one transaction
    db.execute(sameIdempotencyKey, event);
    producer.send(record);
    producer.commitTransaction();
} catch (Exception e) {
    producer.abortTransaction();
    throw e;  // replay must be safe for both sides
}$code$),
    ('kafka-exactly-once-processing', 3, 'Operational cost of transactional pipelines', $body$Transactions are not free: they add coordinator round trips for every commit and require broker-side transaction state log replication; Kafka Streams exactly-once workloads expect at least three brokers by default. Until a transaction commits, read_committed readers of the affected partitions cannot advance past it, and transaction.timeout.ms defaults to one minute, so slow processing can inflate end-to-end latency. Fencing, aborts, and rebalances all need monitoring and runbooks. Estimate the latency and throughput budget before adopting transactions, and benchmark with realistic batch sizes instead of assuming a small overhead.$body$, $code$# Kafka Streams exactly-once requires broker support
processing.guarantee=exactly_once_v2

# broker defaults for production exactly-once
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=2$code$),
    ('kafka-schema-evolution', 1, 'A registry makes compatibility explicit', $body$A schema registry stores versioned schemas per subject and validates new versions against a compatibility policy, usually backward compatibility by default: a new schema can read data written with the previous one. Compatibility modes can be backward, forward, full, or their transitive variants, and the right choice depends on whether consumers or producers upgrade first. Without a registry, compatibility lives in tribal knowledge and breaks at deploy time. Agree per subject which changes are allowed before anyone edits a schema. The registry is a control point, not a convenience: wire it into build and deploy pipelines.$body$, $code$# register a new schema version for a subject
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data @payment-event.avsc \
  http://schema-registry:8081/subjects/payments-value/versions

# check compatibility against the latest version
curl -X POST http://schema-registry:8081/compatibility/subjects/\
payments-value/versions/latest$code$),
    ('kafka-schema-evolution', 2, 'Make changes that can be read back', $body$In Avro, adding a field with a default value is backward compatible because readers can fill the gap; adding a required field without a default is not. In Protobuf, field numbers are permanent: never reuse or renumber them, and add new optional fields instead of changing existing types. In both formats, tighten validation with new fields rather than by changing the meaning of an existing field in place. Ship one schema change per deploy so rollbacks stay possible. Compatibility tooling catches structural mistakes, but semantics remain a human decision: a field can keep its name and still mean something new.$body$, $code${
  "type": "record",
  "name": "PaymentEvent",
  "fields": [
    {"name": "paymentId", "type": "string"},
    {"name": "amount", "type": "long"},
    {"name": "currency", "type": "string", "default": "EUR"}
  ]
}$code$),
    ('kafka-schema-evolution', 3, 'Roll out consumers before producers', $body$With backward compatibility, deploy consumers first: they must tolerate the new schema while producers still emit the old one, then upgrade producers, and only then rely on new fields. Forward compatibility reverses that order, and full compatibility supports either sequence. This ordering belongs in the rollout checklist for every producer and consumer of the subject. Keep old schemas registered so historical data remains readable, and treat schema deletion as a deliberate, rare, cross-team event. Automate the compatibility check so an incompatible change fails before merge rather than during a deploy.$body$, $code$<!-- CI compatibility check before merge -->
<plugin>
  <groupId>io.confluent</groupId>
  <artifactId>kafka-schema-registry-maven-plugin</artifactId>
  <configuration>
    <subjects>
      <payments-value>src/main/avro/payment-event.avsc</payments-value>
    </subjects>
  </configuration>
</plugin>$code$),
    ('kafka-retries-and-dead-letters', 1, 'Retry off the poll loop', $body$Retrying inside the consumer loop blocks poll and can exceed max.poll.interval.ms, triggering a rebalance mid-retry. The scalable pattern publishes failures to retry topics with increasing delays, for example retry-5s, retry-1m, and retry-10m, each consumed with the same processing logic, and routes records that still fail to a dead-letter topic. Delay can be implemented with scheduled consumers or by timestamp checks on paused partitions. Retrying through separate topics preserves ordering only for keys that follow the same retry path, so keep per-key sequences together and cap attempts explicitly.$body$, $code$if (attempt < MAX_ATTEMPTS) {
    producer.send(new ProducerRecord<>(
        retryTopic(attempt), record.key(), record.value()));
} else {
    producer.send(new ProducerRecord<>("orders-dlq", record.key(), record.value()));
}
consumer.commitSync();$code$),
    ('kafka-retries-and-dead-letters', 2, 'Design the dead-letter record', $body$A dead-letter topic is an interface boundary, so its records must be self-describing. Include the original topic, partition, and offset; the consumer group and attempt count; the exception class and message; the failure timestamp; and a stable event id, either as headers or in an envelope. Record-level metadata beats log scraping during an incident. Configure retention long enough for investigation and replay, and monitor dead-letter depth and age as first-class alerts, because a growing dead-letter queue is silent data loss for downstream users. Classify errors: permanent validation failures and transient infrastructure failures deserve different handling and often different topics.$body$, $code$record.headers()
    .add("dlq.origin", origin.topic().getBytes(UTF_8))
    .add("dlq.attempts", String.valueOf(attempts).getBytes(UTF_8))
    .add("dlq.error", error.getClass().getName().getBytes(UTF_8));
producer.send(new ProducerRecord<>(
    "orders-dlq", null, record.key(), payload, record.headers()));$code$),
    ('kafka-retries-and-dead-letters', 3, 'Replay is a documented procedure', $body$Replay turns a dead-letter topic from a graveyard into a recovery tool, but only when it is safe and routine. The runbook should cover how to filter records for replay, how to fix the cause first, how to rate-limit replay so it does not overwhelm downstream systems, and how to preserve key order. Replay tooling must route through the same processing path as live traffic and use idempotent writes, because replay plus redelivery will duplicate effects if it does not. Assign an owner and an expiry date to every dead-letter topic, and rehearse the procedure before the incident that needs it.$body$, $code$# inspect dead-letter records first
kcat -b localhost:9092 -C -t orders-dlq -o beginning -e -c 10

# replay selected records back through the processing topic
kcat -b localhost:9092 -C -t orders-dlq -f '%k|%s\n' -o beginning -e \
  | kcat -b localhost:9092 -P -t orders -K '|'$code$),
    ('kafka-transactions', 1, 'The transactional producer lifecycle', $body$A transactional producer sets transactional.id, which both enables transactions and provides the identity used for fencing. initTransactions must run once before any transaction; each unit of work is beginTransaction, one or more sends, then commitTransaction, or abortTransaction on failure. If another producer starts with the same transactional.id, the broker aborts the older instance in-flight transaction and the old client fails with ProducerFencedException, which must be treated as fatal: close the producer and stop. Authorization failures and out-of-order sequence errors are likewise not retryable at the call site.$body$, $code$props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "payments-tx-1");
producer.initTransactions();
try {
    producer.beginTransaction();
    producer.send(new ProducerRecord<>("payments", key, value));
    producer.commitTransaction();
} catch (KafkaException e) {
    producer.abortTransaction();
}$code$),
    ('kafka-transactions', 2, 'Isolation levels change what readers see', $body$The isolation.level setting controls what a consumer can read from transactional partitions. The default, read_uncommitted, returns all records, including those from open or aborted transactions. read_committed returns only committed records and holds readers back at the first open transaction, which is what makes transactional output invisible until commit. Pipelines that consume transactional output should set read_committed; otherwise aborted records leak downstream. One cost to remember: a stalled open transaction blocks read_committed consumers of the affected partitions until it commits or hits transaction.timeout.ms, which defaults to one minute.$body$, $code$props.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
props.put(ConsumerConfig.GROUP_ID_CONFIG, "payments-projector");
// read_committed hides aborted records from this consumer
// but does not deduplicate a non-transactional producer$code$),
    ('kafka-transactions', 3, 'Mistakes that silently void the guarantee', $body$Sharing one transactional producer across threads interleaves transactions and breaks atomicity; each processing thread or instance needs its own producer. Committing consumer offsets with the plain consumer API after sendOffsetsToTransaction creates a competing commit that can advance past uncommitted work. Forgetting read_committed on downstream consumers exposes aborted records. Failing to restart a fenced producer leaves a zombie that cannot commit, and mixing transactional with non-transactional writers on one topic makes visibility unpredictable. Put these points on a code review checklist, because none of them fails loudly at first.$body$, $code$// wrong: shared across threads
static final KafkaProducer<String, String> SHARED = create();

// right: one transactional producer per processing instance
try (KafkaProducer<String, String> producer = createTransactional()) {
    runLoop(producer);
}$code$),
    ('kafka-streams-essentials', 1, 'A stream is a table in motion', $body$Kafka Streams models data as KStream, an append-only sequence of events, and KTable, a changelog that holds the latest value per key. The two are views of the same log: replaying a stream rebuilds a table, and a table can be converted back to a stream of changes. Aggregations turn a stream into a table of running results, which is why counts, sums, and joins compose naturally. This duality is the core mental model: choose KStream when every occurrence matters, and KTable when only the current value per key matters.$body$, $code$StreamsBuilder builder = new StreamsBuilder();
KStream<String, Order> orders = builder.stream("orders");
KTable<String, Long> countsByCustomer =
    orders.groupBy((key, order) -> order.customerId())
          .count();
countsByCustomer.toStream().to("customer-order-counts");$code$),
    ('kafka-streams-essentials', 2, 'Keyed state and repartitioning costs', $body$Stateful operations such as count, reduce, and aggregate work per key, which means records must be partitioned by that key. Grouping by a key that differs from the input partitioning triggers an internal repartition topic, adding latency, storage, and another failure surface. Design the topology so the first meaningful key choice happens in the producer, not in Streams; explicit repartitioning is sometimes correct but should be visible and documented. Joins require co-partitioned inputs, so matching partition counts matter. Think through keys on a whiteboard before writing the topology.$body$, $code$KStream<String, Order> stream = builder.stream("orders");
KTable<String, Long> perRegion = stream
    .groupBy((key, order) -> order.region())   // repartition topic
    .count(Materialized.as("orders-by-region"));
// choose keys in the producer to avoid this shuffle$code$),
    ('kafka-streams-essentials', 3, 'State stores, changelogs, and recovery', $body$Streams keeps operator state in a state store, backed by RocksDB by default, and writes every change to a Kafka changelog topic for durability. On a rebalance the task moves to another instance, which rebuilds state from the changelog, so restore time scales with state size. Standby replicas reduce that recovery window at the cost of extra resources, and interactive queries let applications read local state directly. Operationally, monitor changelog lag and store disk usage, and remember that state is derived: losing a local store costs time, not correctness.$body$, $code$props.put(StreamsConfig.APPLICATION_ID_CONFIG, "order-counts-v1");
props.put(StreamsConfig.NUM_STANDBY_REPLICAS_CONFIG, 1);
props.put(StreamsConfig.STATE_DIR_CONFIG, "/var/lib/kafka-streams");
props.put(StreamsConfig.PROCESSING_GUARANTEE_CONFIG, "exactly_once_v2");
// state restores from the changelog topic after rebalances$code$),
    ('kafka-connect-essentials', 1, 'Connectors run as managed tasks', $body$Kafka Connect moves data without custom consumer code: source connectors import data into Kafka, sink connectors export it to external systems. In distributed mode, workers form a cluster, store connector configuration, offsets, and status in internal compacted topics, and split a connector workload into tasks that scale toward source or sink capacity. Because offsets and retries are framework-managed, a connector is an operational component with state, not a script. Plan for its internal topics, task count, and rebalances the same way you would for a service. Standalone mode is for development and single-process edge cases.$body$, $code$curl -X POST -H "Content-Type: application/json" \
  --data @debezium-orders.json \
  http://connect:8083/connectors

# distributed-mode worker essentials
group.id=connect-cluster
config.storage.topic=connect-configs
offset.storage.topic=connect-offsets
status.storage.topic=connect-status$code$),
    ('kafka-connect-essentials', 2, 'Single message transforms shape data in flight', $body$Single message transforms (SMTs) modify each record as it passes through a connector: masking fields, renaming or routing topics, reformatting timestamps, or flattening nested structures. They are configured, not coded, and applied as an ordered chain, so order matters and debugging starts with the chain. Use SMTs for adaptation and hygiene, not for business logic that deserves tests and ownership. They are also upgrade-sensitive: a connector or transform upgrade can change behavior, so keep configurations in version control and test upgrades against real sample records. When logic outgrows a few transforms, switch to Kafka Streams.$body$, $code$"transforms": "mask,routes",
"transforms.mask.type": "org.apache.kafka.connect.transforms.MaskField$Value",
"transforms.mask.fields": "cardNumber",
"transforms.mask.replacement": "***",
"transforms.routes.type": "org.apache.kafka.connect.transforms.RegexRouter",
"transforms.routes.regex": "dbz\\.orders",
"transforms.routes.replacement": "orders-cdc"$code$),
    ('kafka-connect-essentials', 3, 'Error handling and operational ownership', $body$Connect classifies failures into connector, task, and record errors; errors.tolerance decides whether a pipeline fails fast or skips records, and a dead-letter queue preserves the skipped ones for inspection. Exactly-once support exists for sink connectors since 0.11 and for source connectors since 3.3, but it is connector-dependent, so verify the specific connector rather than assuming. Each pipeline needs an owner, pinned connector versions, and alerting on task failures, rebalance churn, and dead-letter growth. Treat connector upgrades like service deployments: review release notes, test in staging, and roll out gradually.$body$, $code$"errors.tolerance": "all",
"errors.deadletterqueue.topic.name": "orders-cdc-dlq",
"errors.deadletterqueue.context.headers.enable": true,
"errors.log.enable": true
# alert on task failure, rebalance churn, and DLQ growth$code$),
    ('kafka-testing-strategies', 1, 'Test against a real broker', $body$Unit tests with mocked producers and consumers verify almost nothing about serialization, partitioning, group coordination, or transactional visibility. A real broker via Testcontainers, for example a KafkaContainer running an Apache Kafka image, gives per-test-class isolation with realistic behavior and startup measured in seconds. Keep a small number of pipeline tests that exercise produce, consume, commit, and retry paths end to end, and use mocks only for narrow unit coverage. Flaky, sleep-based tests destroy trust; prefer wait strategies that poll for observable state instead of fixed delays.$body$, $code$try (KafkaContainer kafka = new KafkaContainer(
        DockerImageName.parse("apache/kafka:4.0.0"))) {
    kafka.start();
    String bootstrap = kafka.getBootstrapServers();
    Producer<String, String> producer = createProducer(bootstrap);
    producer.send(new ProducerRecord<>("orders", "o-1", "created")).get();
    Consumer<String, String> consumer = createConsumer(bootstrap);
    consumer.subscribe(List.of("orders"));
    assertThat(recordsWithin(consumer, Duration.ofSeconds(10))).hasSize(1);
}$code$),
    ('kafka-testing-strategies', 2, 'Contract tests pin the event agreement', $body$A topic is a contract between a producing team and every consuming team, and it needs tests just like an HTTP API. Contract tests verify that the schema a producer emits is compatible with what consumers expect, that samples deserialize with the consumer generated classes, and that required fields and semantics match. Run registry compatibility checks in CI so an incompatible schema fails the build, and keep golden sample messages for regression. Version the test fixtures with the event version so both old and new consumers can be exercised during a rollout. Ownership without tests is a promise nobody verifies.$body$, $code$// CI: fail the build when a schema breaks compatibility
mvn schema-registry:test-compatibility \
  -DschemaRegistryUrl=http://registry:8081 \
  -Dsubject=orders-value

// consumer side: golden sample from the producer repository
assertThat(OrderEvent.parse(sample("order-v2.json")))
    .hasFieldOrPropertyWithValue("status", "PLACED");$code$),
    ('kafka-testing-strategies', 3, 'Rehearse failure paths deliberately', $body$Production incidents in event pipelines come from rebalances mid-batch, duplicate delivery, poison records, transaction aborts, and downstream outages, so tests should cover those paths rather than assume them away. Simulate slow processing to cross the poll interval, stop a consumer mid-batch, and verify that redelivery is idempotent. Feed malformed records and assert they land in the dead-letter queue with useful headers and no infinite retry loop. Assert ordering per key where it matters. These tests are slower and less glamorous than unit tests, but they convert incident learning into regression protection.$body$, $code$// poison record: assert DLQ routing and no infinite retry
producer.send(new ProducerRecord<>("orders", "bad-key", "{not-json"));
await().atMost(Duration.ofSeconds(30))
    .until(() -> dlqMessages("orders-dlq").hasSize(1));
assertThat(dlqHeader("dlq.error")).contains("DeserializationException");$code$),
    ('event-sourcing-fundamentals', 1, 'Events are the source of truth', $body$Event sourcing stores every state change as an immutable event in an append-only log, and derives current state by replaying those events. A Kafka topic with per-aggregate keys can serve as that log, giving durable ordering per aggregate and a tunable retention window. The benefits are auditable history, temporal queries, and a natural integration feed without separate change-data-capture machinery. The costs are equally real: events become durable contracts, so schema governance and replay tooling must exist from day one. If you cannot afford to own those two capabilities, event sourcing will hurt more than it helps.$body$, $code$-- events are the truth; state tables are derived caches
INSERT INTO event_store (aggregate_id, sequence, event_type, payload)
VALUES (:aggregateId, :nextSequence, 'OrderPlaced', :payload::jsonb);
-- corrections are new events, never updates or deletes
-- current state is rebuilt by replaying events in sequence order$code$),
    ('event-sourcing-fundamentals', 2, 'Rebuilding aggregates and snapshots', $body$An aggregate loads by reading its events in sequence order and applying them to a fresh state; commands validate against that state and append new events. Kafka partitioning by aggregate id keeps those events ordered, which is why key design is non-negotiable. Replay cost grows with history length, so snapshots store the state at a known sequence and later loads start from the snapshot plus newer events. A snapshot is a cache, not the truth: it can be deleted and rebuilt, and rebuilds should be routine before major refactors. Snapshot cadence follows your replay time budget.$body$, $code$Order order = new Order();
for (Event e : eventStore.read(orderId)) {   // ordered by sequence
    order.apply(e);
}
// snapshot: state at a sequence, rebuilt like any other cache
snapshotStore.save(orderId, order.sequence(), order.toSnapshot());$code$),
    ('event-sourcing-fundamentals', 3, 'When event sourcing is overkill', $body$If consumers only need current state, and audit, temporal queries, or event-driven integration are not requirements, a transactional database with a change feed is simpler and cheaper. Event sourcing demands disciplined schema evolution, event migration and upcasting, projection infrastructure, replay tooling, and a team comfortable with eventually consistent read models. Hybrid designs often fit best: keep a relational current-state model as the source of truth and publish domain events for integration, adding event sourcing only for the few aggregates whose history truly matters. Choose the pattern for the capabilities it unlocks, not for architectural fashion.$body$, $code$// start with a change feed, not a full rewrite
@Transactional
public void placeOrder(OrderCommand cmd) {
    orderRepository.save(Order.place(cmd));
    outboxRepository.save(OrderPlaced.from(cmd));  // published by a relay
}$code$),
    ('cqrs-fundamentals', 1, 'Separate write and read models', $body$CQRS splits the path that changes state from the paths that read it. Commands load the write model, enforce invariants, and append changes; queries read denormalized models shaped for screens and reports instead of joining normalized tables at request time. The write side stays small and transactional, while read models can be tuned, cached, and scaled independently. Importantly, CQRS does not require event sourcing: a relational write database plus projections maintained from its change stream is a valid, common shape. Adopt it when read and write workloads genuinely diverge, or when projections would replace existing reporting tables anyway.$body$, $code$// write side: validate and persist the command
@Transactional
public OrderId placeOrder(PlaceOrder cmd) { ... }

// read side: one query against a denormalized model
SELECT id, status, customer_name, total_cents
FROM order_summary
WHERE customer_id = :customerId;$code$),
    ('cqrs-fundamentals', 2, 'Projections are derived and replayable', $body$A projection consumes change events and maintains a read store, updating rows idempotently so replays converge to the same result. Track the projection position, typically a consumer offset, per projector; treating it as part of the read model lets you rebuild that model from a known point without guessing. Rebuilds are routine operations, so keep the read schema disposable and never let it become the only home of data. When multiple projections feed one store, isolate them by table or schema so one stalled projector cannot corrupt another. Idempotent upserts beat insert-only pipelines.$body$, $code$while (running) {
    for (ConsumerRecord<String, OrderEvent> r :
            consumer.poll(Duration.ofMillis(200))) {
        readStore.upsert(r.value().orderId(), r.value().status());
        // idempotent by key; safe to replay from any committed offset
    }
    consumer.commitSync(Duration.ofSeconds(5));
}$code$),
    ('cqrs-fundamentals', 3, 'Make consistency expectations explicit', $body$Asynchronous projections mean a command can succeed while queries still return the previous state, so read-your-writes is not free. Options include routing a user reads to the write model for a short window, returning the new version with the command response, or showing optimistic state until the projection catches up. Whichever you choose, measure projection lag and expose it as an objective instead of discovering it through user reports. Also avoid dual writes from application code to both the write model and the read store: without atomicity they diverge, so derive the read model from a single ordered stream.$body$, $code$SELECT max(now() - event_occurred_at) AS projection_lag
FROM order_summary_progress;

-- alert when lag exceeds the user-visible staleness budget
-- budget: p99 lag under 2s for the order tracking screen$code$),
    ('event-schema-governance', 1, 'Names and envelopes carry meaning', $body$Event contracts age slowly, so naming deserves the same care as API paths. Use past-tense domain names for events such as OrderPlaced and PaymentCaptured, consistent topic names such as domain.entity.event, and a stable envelope with event id, occurred timestamp, schema version, and correlation id. The envelope gives every consumer the metadata it needs without inspecting payload strings, and version fields support observability and debugging. Versioning inside the topic name is a last resort because it multiplies topics; prefer compatible payload evolution. Freeze the naming rules in a lightweight standard that CI can check.$body$, $code${
  "eventId": "7f2c...",
  "eventType": "OrderPlaced",
  "occurredAt": "2026-10-05T13:20:00Z",
  "schemaVersion": 3,
  "correlationId": "req-8a1..."
}$code$),
    ('event-schema-governance', 2, 'Ownership and change policy', $body$Every topic and event needs an owning team accountable for compatibility, retention, and incidents; a topic without an owner is a liability because nobody can approve or reject changes. Publish a change policy covering who reviews schema changes, which compatibility mode applies, how deprecations are announced, and the minimum supported lifetime for old versions. Consumers must be enumerable, because a migration you cannot map is a migration you cannot finish. Record ownership in a catalog alongside retention and data classification, and reference it from the registry subject. Governance works when it is small, visible, and enforced by CI.$body$, $code$# catalog entry checked in next to the schema
owner: payments-team
subject: payments-value
compatibility: BACKWARD
retention: 30d
consumers: [ledger, notifications, analytics]$code$),
    ('event-schema-governance', 3, 'Registries and docs as enforcement', $body$The registry enforces compatibility at publish time, so an incompatible schema cannot be registered without an explicit policy change. Pair it with a catalog that documents each subject: owner, description, retention, classification, and example payloads generated from the schema so documentation cannot drift. Run compatibility checks in pull requests, and make production deploys consume only registry-approved schemas rather than local files. Generation and verification should be automatic; review effort belongs on semantics, not formatting. If an event is not registered and cataloged, other teams cannot safely depend on it, and it is not yet a contract.$body$, $code$mvn schema-registry:validate \
  -DschemaRegistryUrl=$REGISTRY_URL
mvn schema-registry:test-compatibility \
  -Dsubject=payments-value -DschemaFile=payment-event.avsc
# deploy only registry-approved schema versions$code$)
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
    'kafka-architecture-brokers-topics', 'kafka-producers-and-acks',
    'kafka-consumers-and-offsets', 'kafka-consumer-groups-and-rebalancing',
    'kafka-partitioning-strategy', 'kafka-delivery-semantics',
    'kafka-exactly-once-processing', 'kafka-schema-evolution',
    'kafka-retries-and-dead-letters', 'kafka-transactions',
    'kafka-streams-essentials', 'kafka-connect-essentials',
    'kafka-testing-strategies', 'event-sourcing-fundamentals',
    'cqrs-fundamentals', 'event-schema-governance'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
