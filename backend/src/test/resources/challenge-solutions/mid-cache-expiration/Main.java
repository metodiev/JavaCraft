import java.time.Duration;
import java.time.Instant;

public class Main {
    public static boolean isFresh(Instant createdAt, Instant now, long ttlSeconds) {
        if (createdAt == null || now == null || ttlSeconds < 0 || now.isBefore(createdAt)) {
            throw new IllegalArgumentException("invalid cache timing");
        }
        return Duration.between(createdAt, now).compareTo(Duration.ofSeconds(ttlSeconds)) < 0;
    }
}
