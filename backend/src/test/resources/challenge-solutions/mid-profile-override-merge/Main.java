import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, String> effective(Map<String, String> base, List<Map<String, String>> overrides) {
        Map<String, String> merged = new LinkedHashMap<>();
        if (base != null) {
            merged.putAll(base);
        }
        if (overrides != null) {
            for (Map<String, String> override : overrides) {
                if (override != null) {
                    merged.putAll(override);
                }
            }
        }
        return merged;
    }
}
