public class Main {
    public static String metric(boolean cpuBound, boolean queueConsumer, boolean latencySensitive) {
        if (queueConsumer) {
            return "QUEUE_DEPTH";
        }
        if (latencySensitive) {
            return "P95_LATENCY";
        }
        if (cpuBound) {
            return "CPU_UTILIZATION";
        }
        return "REQUESTS_PER_SECOND";
    }
}
