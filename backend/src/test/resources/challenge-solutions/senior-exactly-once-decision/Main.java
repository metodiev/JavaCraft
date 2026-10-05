public class Main {
    public static String advise(boolean idempotentConsumer, boolean transactionalSink, boolean crossSystemWrites) {
        if (crossSystemWrites) {
            return "OUTBOX";
        }
        if (idempotentConsumer) {
            return "IDEMPOTENT_CONSUMER";
        }
        if (transactionalSink) {
            return "TRANSACTIONS";
        }
        return "AT_LEAST_ONCE";
    }
}
