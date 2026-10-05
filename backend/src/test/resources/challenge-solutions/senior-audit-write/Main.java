import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class Main {
    private static final List<String> OUTCOMES = List.of("success", "failure", "denied");
    private static final List<String> SECRET_WORDS = List.of("password", "secret", "token");
    private static final String REDACTED = "[redacted]";
    private static final String UNKNOWN = "unknown";

    public static Map<String, Object> auditEntry(String actor, String action, String target, String outcome) {
        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("actor", field(actor));
        entry.put("action", field(action));
        entry.put("target", field(target));
        entry.put("outcome", outcome(outcome));
        return entry;
    }

    private static String field(String value) {
        if (value == null || value.isBlank()) {
            return UNKNOWN;
        }
        String trimmed = value.trim();
        String lower = trimmed.toLowerCase(Locale.ROOT);
        for (String secret : SECRET_WORDS) {
            if (lower.contains(secret)) {
                return REDACTED;
            }
        }
        int run = 0;
        for (int i = 0; i < trimmed.length(); i++) {
            if (Character.isDigit(trimmed.charAt(i))) {
                run++;
                if (run >= 12) {
                    return REDACTED;
                }
            } else {
                run = 0;
            }
        }
        return trimmed;
    }

    private static String outcome(String value) {
        if (value == null || value.isBlank()) {
            return UNKNOWN;
        }
        String lower = value.trim().toLowerCase(Locale.ROOT);
        return OUTCOMES.contains(lower) ? lower : UNKNOWN;
    }
}
