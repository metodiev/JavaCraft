public class Main {
    public static String chooseCollector(int heapGb, int p99PauseMillis, boolean throughputCritical) {
        if (heapGb <= 0) {
            return "Serial";
        }
        if (heapGb >= 16) {
            if (p99PauseMillis <= 100 && !throughputCritical) {
                return "ZGC";
            }
            return "G1";
        }
        return p99PauseMillis <= 200 ? "G1" : "Parallel";
    }
}
