import java.util.Locale;

public class Main {
    public static String levelFor(String event) {
        if (event == null || event.isBlank()) {
            throw new IllegalArgumentException("event category must not be blank");
        }
        return switch (event.trim().toLowerCase(Locale.ROOT)) {
            case "expected-failure" -> "WARN";
            case "unexpected-failure" -> "ERROR";
            case "routine-detail" -> "DEBUG";
            case "lifecycle" -> "INFO";
            default -> throw new IllegalArgumentException("unknown event category: " + event);
        };
    }
}
