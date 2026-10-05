import java.time.Instant;

public class Main {
    public static String format(Instant instant) {
        // TODO: format in UTC with ISO-8601 seconds precision
        return instant == null ? "" : instant.toString();
    }
}
