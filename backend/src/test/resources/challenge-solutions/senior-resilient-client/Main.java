import java.time.Duration;

public class Main {
    public static long nextDelayMillis(int attempt, long baseMillis, long maxMillis) {
        if (attempt < 1 || baseMillis < 1 || maxMillis < baseMillis) {
            throw new IllegalArgumentException("invalid backoff arguments");
        }
        long delay = baseMillis;
        for (int i = 1; i < attempt; i++) {
            if (delay >= maxMillis - delay) {
                return maxMillis;
            }
            delay *= 2;
        }
        return Math.min(delay, maxMillis);
    }

    public static boolean shouldRetry(int attempt, int maxAttempts, boolean transientFailure,
                                      Duration elapsed, Duration deadline) {
        return transientFailure && attempt < maxAttempts && elapsed.compareTo(deadline) < 0;
    }
}
