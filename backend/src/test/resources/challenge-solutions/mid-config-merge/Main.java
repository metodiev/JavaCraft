import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Main {
    private static final String SECRET_PREFIX = "secret:";

    public static Map<String, String> effective(List<Map<String, String>> layers) {
        Map<String, String> result = new LinkedHashMap<>();
        Set<String> secretKeys = new HashSet<>();
        if (layers == null) {
            return result;
        }
        for (Map<String, String> layer : layers) {
            if (layer == null) {
                continue;
            }
            for (Map.Entry<String, String> entry : layer.entrySet()) {
                String rawKey = entry.getKey();
                if (rawKey == null) {
                    continue;
                }
                boolean secret = rawKey.startsWith(SECRET_PREFIX);
                String key = secret ? rawKey.substring(SECRET_PREFIX.length()) : rawKey;
                if (key.isEmpty()) {
                    continue;
                }
                if (secretKeys.contains(key) && !secret) {
                    continue;
                }
                result.put(key, entry.getValue());
                if (secret) {
                    secretKeys.add(key);
                } else {
                    secretKeys.remove(key);
                }
            }
        }
        return result;
    }
}
