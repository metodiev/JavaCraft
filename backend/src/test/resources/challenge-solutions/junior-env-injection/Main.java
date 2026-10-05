import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public class Main {
    public static Map<String, String> toEnvironment(Map<String, String> config) {
        Map<String, String> result = new LinkedHashMap<>();
        if (config == null) {
            return result;
        }
        for (Map.Entry<String, String> entry : config.entrySet()) {
            if (entry.getKey() == null) {
                continue;
            }
            result.put(entry.getKey().toUpperCase(Locale.ROOT).replace('.', '_').replace('-', '_'),
                    entry.getValue());
        }
        return result;
    }
}
