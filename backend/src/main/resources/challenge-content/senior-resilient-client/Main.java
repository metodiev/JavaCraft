import java.time.Duration;

public class Main {
    public static long nextDelayMillis(int attempt, long baseMillis, long maxMillis) {
        // TODO: capped exponential backoff
        return baseMillis;
    }

    public static boolean shouldRetry(int attempt, int maxAttempts, boolean transientFailure,
                                      Duration elapsed, Duration deadline) {
        // TODO: retry only transient failures within the attempt and time budgets
        return true;
    }
}
