import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> flatten(Map<String, Object> yaml) {
        if (yaml == null) {
            throw new IllegalArgumentException("yaml must not be null");
        }
        Map<String, String> flat = new LinkedHashMap<>();
        flattenInto("", yaml, flat);
        return flat;
    }

    private static void flattenInto(String prefix, Map<String, Object> yaml, Map<String, String> flat) {
        for (Map.Entry<String, Object> entry : yaml.entrySet()) {
            String key = entry.getKey();
            if (key == null) {
                throw new IllegalArgumentException("keys must not be null");
            }
            String path = prefix.isEmpty() ? key : prefix + "." + key;
            Object value = entry.getValue();
            if (value == null) {
                continue;
            }
            if (value instanceof Map<?, ?> nested) {
                Map<String, Object> child = new LinkedHashMap<>();
                for (Map.Entry<?, ?> nestedEntry : nested.entrySet()) {
                    if (!(nestedEntry.getKey() instanceof String nestedKey)) {
                        throw new IllegalArgumentException("nested keys must be strings");
                    }
                    child.put(nestedKey, nestedEntry.getValue());
                }
                flattenInto(path, child, flat);
            } else if (value instanceof String || value instanceof Number
                    || value instanceof Boolean || value instanceof Character) {
                flat.put(path, String.valueOf(value));
            } else {
                throw new IllegalArgumentException("unsupported value type: " + value.getClass().getName());
            }
        }
    }
}
