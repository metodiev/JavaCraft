import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> parseProperties(String text) {
        Map<String, String> props = new LinkedHashMap<>();
        if (text == null || text.isEmpty()) {
            return props;
        }
        for (String rawLine : text.split("\n", -1)) {
            String line = rawLine.trim();
            if (line.isEmpty() || line.startsWith("#")) {
                continue;
            }
            int equals = line.indexOf('=');
            int colon = line.indexOf(':');
            int separator;
            if (equals < 0) {
                separator = colon;
            } else if (colon < 0) {
                separator = equals;
            } else {
                separator = Math.min(equals, colon);
            }
            if (separator < 0) {
                continue;
            }
            String key = line.substring(0, separator).trim();
            String value = line.substring(separator + 1).trim();
            if (!key.isEmpty()) {
                props.put(key, value);
            }
        }
        return props;
    }
}
