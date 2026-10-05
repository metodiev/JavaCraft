import java.time.DateTimeException;
import java.time.Instant;
import java.time.format.DateTimeFormatter;

public class Main {
    private static final long REPRODUCIBLE_EPOCH_SECONDS = 315532800L;

    public static String sourceDateEpoch(Long epochSeconds) {
        long seconds = epochSeconds == null ? REPRODUCIBLE_EPOCH_SECONDS : epochSeconds;
        try {
            return DateTimeFormatter.ISO_INSTANT.format(Instant.ofEpochSecond(seconds));
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("unsupported timestamp: " + epochSeconds, e);
        }
    }
}
