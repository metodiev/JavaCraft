import java.time.Duration;

public class Main {
    public static boolean shouldRetry(int attempt, int maxAttempts, Duration remaining, boolean transientFailure) {
        if (attempt < 1 || maxAttempts < 1 || remaining == null) {
            throw new IllegalArgumentException("invalid retry arguments");
        }
        return transientFailure && attempt < maxAttempts && !remaining.isZero() && !remaining.isNegative();
    }
}
