import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public class Main {
    private static final String[] REQUIRED = {"actor", "action", "target", "timestamp"};
    private static final Set<String> SECRET_KEYS = Set.of("password", "token", "secret", "apikey", "api_key", "credential");

    public static List<String> violations(Map<String, Object> entry) {
        List<String> out = new ArrayList<>();
        for (String field : REQUIRED) {
            Object value = entry == null ? null : entry.get(field);
            if (value == null || (value instanceof String text && text.isBlank())) {
                out.add("missing " + field);
            }
        }
        if (entry != null) {
            for (String key : entry.keySet()) {
                if (key != null && SECRET_KEYS.contains(key.toLowerCase(Locale.ROOT))) {
                    out.add("secret material must not be logged");
                    break;
                }
            }
        }
        return out;
    }
}
