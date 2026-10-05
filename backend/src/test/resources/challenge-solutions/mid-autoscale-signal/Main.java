public class Main {
    public static String signal(boolean queueBacklog, boolean cpuBound, boolean latencySensitive) {
        if (queueBacklog) {
            return "QUEUE_BACKLOG";
        }
        if (latencySensitive) {
            return "REQUEST_LATENCY";
        }
        if (cpuBound) {
            return "CPU_UTILIZATION";
        }
        return "CONCURRENCY";
    }
}
