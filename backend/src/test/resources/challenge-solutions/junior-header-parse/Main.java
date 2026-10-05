import java.util.*;

public class Main {
    public static Map<String, String> parse(String rawHeaders) {
        Map<String, String> headers = new LinkedHashMap<>();
        if (rawHeaders == null) {
            return headers;
        }
        for (String line : rawHeaders.split("\n", -1)) {
            String trimmed = line.endsWith("\r") ? line.substring(0, line.length() - 1) : line;
            if (trimmed.isBlank()) {
                continue;
            }
            int colon = trimmed.indexOf(':');
            if (colon < 0) {
                continue;
            }
            String name = trimmed.substring(0, colon).trim();
            if (name.isEmpty()) {
                continue;
            }
            headers.put(name.toLowerCase(Locale.ROOT), trimmed.substring(colon + 1).trim());
        }
        return headers;
    }
}
