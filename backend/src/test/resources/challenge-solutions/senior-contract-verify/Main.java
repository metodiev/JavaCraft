import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> contract, Map<String, Object> actual) {
        List<String> report = new ArrayList<>();
        if (contract == null || actual == null) {
            return report;
        }
        for (Map.Entry<String, Object> entry : contract.entrySet()) {
            String key = entry.getKey();
            String expectedType = String.valueOf(entry.getValue());
            if (!actual.containsKey(key)) {
                report.add("missing: " + key);
                continue;
            }
            String actualType = typeOf(actual.get(key));
            if (!expectedType.equals(actualType)) {
                report.add("type: " + key + " expected " + expectedType + " but was " + actualType);
            }
        }
        Collections.sort(report);
        return report;
    }

    private static String typeOf(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof Number) {
            return "number";
        }
        if (value instanceof CharSequence) {
            return "string";
        }
        if (value instanceof Boolean) {
            return "boolean";
        }
        if (value instanceof Map) {
            return "object";
        }
        if (value instanceof List || value instanceof Object[]) {
            return "array";
        }
        return value.getClass().getSimpleName().toLowerCase();
    }
}
