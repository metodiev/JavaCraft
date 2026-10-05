import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class Main {
    public static Map<String, String> parseFilters(String query) {
        Map<String, String> filters = new LinkedHashMap<>();
        if (query == null) {
            return filters;
        }
        String input = query.startsWith("?") ? query.substring(1) : query;
        for (String pair : input.split("&", -1)) {
            if (pair.isBlank()) {
                continue;
            }
            int equals = pair.indexOf('=');
            String rawKey = equals < 0 ? pair : pair.substring(0, equals);
            String rawValue = equals < 0 ? "" : pair.substring(equals + 1);
            String key = decode(rawKey).trim();
            if (key.isEmpty()) {
                continue;
            }
            filters.put(key, decode(rawValue));
        }
        return filters;
    }

    private static String decode(String raw) {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        for (int i = 0; i < raw.length(); i++) {
            char c = raw.charAt(i);
            if (c == '+') {
                bytes.write(' ');
            } else if (c == '%' && i + 2 < raw.length()
                    && Character.digit(raw.charAt(i + 1), 16) >= 0
                    && Character.digit(raw.charAt(i + 2), 16) >= 0) {
                bytes.write(Integer.parseInt(raw.substring(i + 1, i + 3), 16));
                i += 2;
            } else {
                bytes.writeBytes(String.valueOf(c).getBytes(StandardCharsets.UTF_8));
            }
        }
        return bytes.toString(StandardCharsets.UTF_8);
    }
}
