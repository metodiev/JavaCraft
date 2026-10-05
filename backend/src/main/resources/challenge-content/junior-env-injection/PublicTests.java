import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("dots become underscores in upper case", () -> {
            Map<String, String> out = Main.toEnvironment(Map.of("spring.datasource.url", "jdbc:pg"));
            return "jdbc:pg".equals(out.get("SPRING_DATASOURCE_URL"));
        });
        t.put("dashes become underscores", () -> {
            Map<String, String> out = Main.toEnvironment(Map.of("my-app.db.host", "db"));
            return "db".equals(out.get("MY_APP_DB_HOST"));
        });
        t.put("an already upper snake key is unchanged", () -> {
            Map<String, String> out = Main.toEnvironment(Map.of("SERVER_PORT", "8080"));
            return "8080".equals(out.get("SERVER_PORT"));
        });
        t.put("values are copied unchanged", () -> {
            Map<String, String> out = Main.toEnvironment(Map.of("app.version", "1.2.3-RC1"));
            return "1.2.3-RC1".equals(out.get("APP_VERSION"));
        });
        t.put("the original key is not also emitted", () -> {
            Map<String, String> out = Main.toEnvironment(Map.of("server.port", "8080"));
            return !out.containsKey("server.port") && !out.containsKey("SERVER.PORT") && out.size() == 1;
        });
        t.put("a null config gives an empty map", () -> Main.toEnvironment(null).isEmpty());
        t.put("an empty config gives an empty map", () -> Main.toEnvironment(Map.of()).isEmpty());
        t.put("null keys are skipped", () -> {
            Map<String, String> config = new HashMap<>();
            config.put(null, "ignored");
            config.put("server.port", "9090");
            Map<String, String> out = Main.toEnvironment(config);
            return out.size() == 1 && "9090".equals(out.get("SERVER_PORT"));
        });
        return t;
    }
}
