import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the core RFC 9457 members are present", () -> {
            Map<String, Object> p = Main.problem("https://errors/validation", "Invalid request", 422, Map.of());
            return "https://errors/validation".equals(p.get("type"))
                    && "Invalid request".equals(p.get("title"))
                    && Integer.valueOf(422).equals(p.get("status"));
        });
        t.put("no errors extension is added when there are no field errors", () -> {
            Map<String, Object> p = Main.problem("about:blank", "Bad request", 400, Map.of());
            return !p.containsKey("errors") && p.size() == 3;
        });
        t.put("field errors become a sorted errors extension", () -> {
            Map<String, List<String>> fields = new LinkedHashMap<>();
            fields.put("reference", List.of("must not be blank"));
            fields.put("quantity", List.of("must be positive"));
            Map<String, Object> p = Main.problem("https://errors/validation", "Invalid", 422, fields);
            @SuppressWarnings("unchecked")
            List<Map<String, String>> errors = (List<Map<String, String>>) p.get("errors");
            return errors.size() == 2
                    && "quantity".equals(errors.get(0).get("field"))
                    && "must be positive".equals(errors.get(0).get("message"))
                    && "reference".equals(errors.get(1).get("field"))
                    && "must not be blank".equals(errors.get(1).get("message"));
        });
        t.put("the originally supplied error map is not modified", () -> {
            Map<String, List<String>> fields = new LinkedHashMap<>();
            fields.put("b", List.of("second"));
            fields.put("a", List.of("first"));
            Main.problem("t", "T", 400, fields);
            return List.copyOf(fields.keySet()).equals(List.of("b", "a"));
        });
        t.put("a null field map produces no errors extension", () -> {
            Map<String, Object> p = Main.problem("t", "T", 400, null);
            return !p.containsKey("errors");
        });
        t.put("a null title is reported as empty text", () -> {
            Map<String, Object> p = Main.problem("t", null, 500, Map.of());
            return "".equals(p.get("title"));
        });
        t.put("a null type uses about:blank", () -> {
            Map<String, Object> p = Main.problem(null, "T", 500, Map.of());
            return "about:blank".equals(p.get("type"));
        });
        t.put("entries with empty messages are skipped", () -> {
            Map<String, List<String>> fields = new LinkedHashMap<>();
            fields.put("a", List.of("first"));
            fields.put("b", List.of());
            fields.put("c", null);
            Map<String, Object> p = Main.problem("t", "T", 422, fields);
            @SuppressWarnings("unchecked")
            List<Map<String, String>> errors = (List<Map<String, String>>) p.get("errors");
            return errors.size() == 1 && "a".equals(errors.get(0).get("field"));
        });
        t.put("the status is the exact integer that was given", () -> {
            Map<String, Object> p = Main.problem("t", "T", 409, Map.of());
            return p.get("status") instanceof Integer value && value == 409;
        });
        return t;
    }
}
