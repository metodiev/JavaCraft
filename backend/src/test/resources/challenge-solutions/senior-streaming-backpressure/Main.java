public class Main {
    public static long requested(long consumerDemand, long buffered, long limit) {
        if (buffered < 0 || limit < 0) {
            throw new IllegalArgumentException("buffered and limit must not be negative");
        }
        long remaining = limit - buffered;
        if (remaining <= 0 || consumerDemand <= 0) {
            return 0;
        }
        return Math.min(consumerDemand, remaining);
    }
}
