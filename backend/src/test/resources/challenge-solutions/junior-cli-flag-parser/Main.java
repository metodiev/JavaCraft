import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> parseFlags(String[] args) {
        Map<String, String> flags = new LinkedHashMap<>();
        if (args == null) {
            return flags;
        }
        for (String arg : args) {
            if (arg == null || !arg.startsWith("--") || arg.length() == 2) {
                continue;
            }
            String body = arg.substring(2);
            int equals = body.indexOf('=');
            if (equals < 0) {
                flags.put(body, "true");
            } else {
                String key = body.substring(0, equals);
                if (!key.isEmpty()) {
                    flags.put(key, body.substring(equals + 1));
                }
            }
        }
        return flags;
    }
}
