import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a later plain layer wins", () -> {
            Map<String, String> out = Main.effective(List.of(Map.of("log.level", "INFO"),
                    Map.of("log.level", "DEBUG")));
            return "DEBUG".equals(out.get("log.level"));
        });
        t.put("keys from every layer are merged", () -> {
            Map<String, String> out = Main.effective(List.of(Map.of("a", "1"), Map.of("b", "2")));
            return "1".equals(out.get("a")) && "2".equals(out.get("b")) && out.size() == 2;
        });
        t.put("a secret beats a later plain layer", () -> {
            Map<String, String> out = Main.effective(List.of(Map.of("secret:db.password", "s1"),
                    Map.of("db.password", "plain")));
            return "s1".equals(out.get("db.password"));
        });
        t.put("a later secret beats an earlier secret", () -> {
            Map<String, String> out = Main.effective(List.of(Map.of("secret:token", "one"),
                    Map.of("secret:token", "two")));
            return "two".equals(out.get("token"));
        });
        t.put("a secret beats an earlier plain value", () -> {
            Map<String, String> out = Main.effective(List.of(Map.of("api.key", "plain"),
                    Map.of("secret:api.key", "sec")));
            return "sec".equals(out.get("api.key"));
        });
        t.put("the secret prefix is stripped from the result", () -> {
            Map<String, String> out = Main.effective(List.of(Map.of("secret:db.password", "s1")));
            return out.containsKey("db.password") && !out.containsKey("secret:db.password");
        });
        t.put("a null layer list gives an empty map", () -> Main.effective(null).isEmpty());
        t.put("null layers are skipped", () -> {
            Map<String, String> out = Main.effective(Arrays.asList(null, Map.of("a", "1")));
            return out.size() == 1 && "1".equals(out.get("a"));
        });
        return t;
    }
}
