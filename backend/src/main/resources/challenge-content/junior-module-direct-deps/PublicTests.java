import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("returns the direct dependencies of a module", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core", "util"));
            return Main.directDependencies(graph, "app").equals(List.of("core", "util"));
        });
        t.put("sorts the result", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("z", "a", "m"));
            return Main.directDependencies(graph, "app").equals(List.of("a", "m", "z"));
        });
        t.put("collapses repeated entries", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core", "core", "util"));
            return Main.directDependencies(graph, "app").equals(List.of("core", "util"));
        });
        t.put("a module with no dependencies yields an empty list", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of());
            return Main.directDependencies(graph, "app").isEmpty();
        });
        t.put("an unknown module yields an empty list", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core"));
            return Main.directDependencies(graph, "missing").isEmpty();
        });
        t.put("null module or null graph yields an empty list", () ->
                Main.directDependencies(null, "app").isEmpty()
                        && Main.directDependencies(Map.of("app", List.of("core")), null).isEmpty());
        t.put("ignores null entries", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", Arrays.asList(null, "core"));
            return Main.directDependencies(graph, "app").equals(List.of("core"));
        });
        return t;
    }
}
