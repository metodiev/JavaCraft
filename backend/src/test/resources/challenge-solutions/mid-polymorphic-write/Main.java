import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> envelope(String type, Map<String, Object> body) {
        if (type == null || body == null) {
            throw new IllegalArgumentException("type and body must not be null");
        }
        if (body.containsKey("type")) {
            throw new IllegalArgumentException("body must not define its own discriminator");
        }
        Map<String, Object> envelope = new LinkedHashMap<>();
        envelope.put("type", type);
        envelope.putAll(body);
        return envelope;
    }
}
