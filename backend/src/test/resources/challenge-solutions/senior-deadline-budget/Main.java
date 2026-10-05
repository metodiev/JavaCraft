public class Main {
    private static final long RESERVE_MILLIS = 10;

    public static long remainingMillis(long deadlineNanos, long nowNanos, int hops) {
        if (deadlineNanos == Long.MAX_VALUE) {
            return 0;
        }
        long remainingMillis = (deadlineNanos - nowNanos) / 1_000_000L;
        long reserve = RESERVE_MILLIS * Math.max(hops, 0);
        return Math.max(remainingMillis - reserve, 0);
    }
}
