import java.time.Duration;

public class Main {
    public static boolean shouldRetry(int attempt, int maxAttempts, Duration remaining, boolean transientFailure) {
        // TODO: retry only when it is safe and there is budget left
        return true;
    }
}
