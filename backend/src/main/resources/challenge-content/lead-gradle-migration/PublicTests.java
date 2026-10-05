import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("leaf modules migrate before the modules that depend on them", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core"));
            graph.put("core", List.of("util"));
            graph.put("util", List.of());
            return Main.migrationOrder(graph).equals(List.of("util", "core", "app"));
        });
        t.put("independent leaf modules are ordered naturally", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("web", List.of("util", "core"));
            graph.put("util", List.of());
            graph.put("core", List.of());
            return Main.migrationOrder(graph).equals(List.of("core", "util", "web"));
        });
        t.put("a diamond is migrated once per module", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("a", "b"));
            graph.put("a", List.of("shared"));
            graph.put("b", List.of("shared"));
            graph.put("shared", List.of());
            return Main.migrationOrder(graph).equals(List.of("shared", "a", "b", "app"));
        });
        t.put("modules mentioned only as dependencies are migrated too", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core"));
            return Main.migrationOrder(graph).equals(List.of("core", "app"));
        });
        t.put("two independent components are both included", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of());
            graph.put("b", List.of());
            return Main.migrationOrder(graph).equals(List.of("a", "b"));
        });
        t.put("a cycle yields an empty order", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("b"));
            graph.put("b", List.of("c"));
            graph.put("c", List.of("a"));
            return Main.migrationOrder(graph).isEmpty();
        });
        t.put("a self-cycle yields an empty order", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("a"));
            return Main.migrationOrder(graph).isEmpty();
        });
        t.put("an empty or null graph yields an empty order", () ->
                Main.migrationOrder(Map.of()).isEmpty() && Main.migrationOrder(null).isEmpty());
        t.put("null dependencies and null module names are ignored", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", Arrays.asList(null, "core"));
            graph.put("", List.of());
            return Main.migrationOrder(graph).equals(List.of("core", "app"));
        });
        return t;
    }
}
