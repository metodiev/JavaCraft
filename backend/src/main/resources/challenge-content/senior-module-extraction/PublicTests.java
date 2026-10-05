import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null input has no order", () -> Main.extractionOrder(null).isEmpty());
        t.put("independent modules come first in name order", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("billing", Set.of());
            deps.put("users", Set.of());
            return Main.extractionOrder(deps).equals(List.of("billing", "users"));
        });
        t.put("a module waits for the modules it depends on", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("orders", Set.of("users"));
            deps.put("users", Set.of());
            return Main.extractionOrder(deps).equals(List.of("users", "orders"));
        });
        t.put("a chain is ordered leaf first", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("web", Set.of("orders"));
            deps.put("orders", Set.of("users"));
            deps.put("users", Set.of());
            return Main.extractionOrder(deps).equals(List.of("users", "orders", "web"));
        });
        t.put("a diamond waits only for real dependencies", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("app", Set.of("orders", "users"));
            deps.put("orders", Set.of("users"));
            deps.put("users", Set.of());
            return Main.extractionOrder(deps).equals(List.of("users", "orders", "app"));
        });
        t.put("a cycle yields no order", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("a", Set.of("b"));
            deps.put("b", Set.of("a"));
            return Main.extractionOrder(deps).isEmpty();
        });
        t.put("a self cycle yields no order", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("a", Set.of("a"));
            deps.put("b", Set.of());
            return Main.extractionOrder(deps).isEmpty();
        });
        t.put("unknown dependencies are ignored", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("a", Set.of("missing"));
            deps.put("b", Set.of());
            return Main.extractionOrder(deps).equals(List.of("a", "b"));
        });
        t.put("a cycle reachable only through a dependency still blocks everything", () -> {
            Map<String, Set<String>> deps = new LinkedHashMap<>();
            deps.put("top", Set.of("mid"));
            deps.put("mid", Set.of("left", "right"));
            deps.put("left", Set.of("right"));
            deps.put("right", Set.of("left"));
            return Main.extractionOrder(deps).isEmpty();
        });
        return t;
    }
}
