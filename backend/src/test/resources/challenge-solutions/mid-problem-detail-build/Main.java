import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class Main {
    public static Map<String, Object> problem(String type, String title, int status, Map<String, List<String>> fieldErrors) {
        Map<String, Object> problem = new LinkedHashMap<>();
        problem.put("type", type == null ? "about:blank" : type);
        problem.put("title", title == null ? "" : title);
        problem.put("status", status);
        if (fieldErrors != null) {
            List<Map<String, String>> errors = new ArrayList<>();
            for (Map.Entry<String, List<String>> entry : new TreeMap<>(fieldErrors).entrySet()) {
                if (entry.getValue() == null) {
                    continue;
                }
                List<String> messages = new ArrayList<>(entry.getValue());
                messages.sort(String::compareTo);
                for (String message : messages) {
                    Map<String, String> error = new LinkedHashMap<>();
                    error.put("field", entry.getKey());
                    error.put("message", message);
                    errors.add(error);
                }
            }
            if (!errors.isEmpty()) {
                problem.put("errors", errors);
            }
        }
        return problem;
    }
}
