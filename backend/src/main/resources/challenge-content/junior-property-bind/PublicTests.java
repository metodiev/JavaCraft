import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the exact key is bound", () -> Main.portFrom(Map.of("app.port", "8080"), 80) == 8080);
        t.put("the relaxed environment variable is accepted", () -> Main.portFrom(Map.of("APP_PORT", "9090"), 80) == 9090);
        t.put("the exact key wins when both names are present", () -> Main.portFrom(Map.of("app.port", "1234", "APP_PORT", "9090"), 80) == 1234);
        t.put("the value is trimmed", () -> Main.portFrom(Map.of("app.port", " 8080 "), 80) == 8080);
        t.put("a missing key or null environment falls back", () -> Main.portFrom(Map.of("server.port", "8080"), 8081) == 8081
                && Main.portFrom(null, 8080) == 8080);
        t.put("an out of range port falls back", () -> Main.portFrom(Map.of("app.port", "0"), 80) == 80
                && Main.portFrom(Map.of("app.port", "65536"), 80) == 80);
        t.put("a non numeric port falls back", () -> Main.portFrom(Map.of("app.port", "http"), 8443) == 8443);
        t.put("an invalid exact value does not fall through to the relaxed name", () -> Main.portFrom(Map.of("app.port", "bad", "APP_PORT", "9090"), 80) == 80);
        t.put("the boundary ports are accepted", () -> Main.portFrom(Map.of("app.port", "1"), 9) == 1
                && Main.portFrom(Map.of("app.port", "65535"), 9) == 65535);
        return t;
    }
}
