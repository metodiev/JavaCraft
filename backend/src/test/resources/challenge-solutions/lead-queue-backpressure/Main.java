public class Main {
    public static boolean mayAccept(int depth, int maxDepth, long oldestAgeMillis, long maxAgeMillis) {
        if (depth < 0 || oldestAgeMillis < 0 || maxDepth < 1 || maxAgeMillis < 1) {
            throw new IllegalArgumentException("invalid backpressure arguments");
        }
        return depth < maxDepth && oldestAgeMillis < maxAgeMillis;
    }
}
