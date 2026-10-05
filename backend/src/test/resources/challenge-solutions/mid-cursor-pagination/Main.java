import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class Main {
    public static String encode(String sortKey, String id) {
        if (sortKey == null || id == null) {
            throw new IllegalArgumentException("sortKey and id must not be null");
        }
        String payload = sortKey + "|" + id;
        return Base64.getUrlEncoder().withoutPadding().encodeToString(payload.getBytes(StandardCharsets.UTF_8));
    }

    public static String[] decode(String cursor) {
        if (cursor == null || cursor.isBlank()) {
            return new String[0];
        }
        String converted = cursor.trim().replace('-', '+').replace('_', '/');
        try {
            byte[] raw = Base64.getDecoder().decode(converted);
            String payload = new String(raw, StandardCharsets.UTF_8);
            int separator = payload.indexOf('|');
            if (separator < 0) {
                return new String[0];
            }
            return new String[] {payload.substring(0, separator), payload.substring(separator + 1)};
        } catch (IllegalArgumentException e) {
            return new String[0];
        }
    }
}
