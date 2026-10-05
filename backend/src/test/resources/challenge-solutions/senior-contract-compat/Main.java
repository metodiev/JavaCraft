import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, String> provided, Map<String, String> required) {
        List<String> result = new ArrayList<>();
        if (required == null) {
            return result;
        }
        for (Map.Entry<String, String> entry : required.entrySet()) {
            String value = provided == null ? null : provided.get(entry.getKey());
            if (value == null) {
                result.add("missing:" + entry.getKey());
            } else if (!value.equals(entry.getValue())) {
                result.add("type:" + entry.getKey());
            }
        }
        Collections.sort(result);
        return result;
    }
}
