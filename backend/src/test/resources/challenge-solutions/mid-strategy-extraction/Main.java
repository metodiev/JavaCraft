import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public class Main {
    public static Map<String, String> extract(Map<String, String> switchCases) {
        Map<String, String> handlers = new LinkedHashMap<>();
        if (switchCases == null) {
            return handlers;
        }
        for (String key : switchCases.keySet()) {
            if (key == null || key.isBlank()) {
                continue;
            }
            handlers.put(key, "ship" + camelCase(key));
        }
        return handlers;
    }

    private static String camelCase(String key) {
        StringBuilder name = new StringBuilder();
        for (String word : key.trim().split("[^A-Za-z0-9]+")) {
            if (word.isEmpty()) {
                continue;
            }
            String lower = word.toLowerCase(Locale.ROOT);
            name.append(Character.toUpperCase(lower.charAt(0))).append(lower.substring(1));
        }
        return name.toString();
    }
}
