import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("dependencies run before the task that needs them", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("b"));
            graph.put("b", List.of("c"));
            return Main.executionOrder(graph, "a").equals(List.of("c", "b", "a"));
        });
        t.put("the dependsOn order decides between independent dependencies", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core", "util"));
            return Main.executionOrder(graph, "app").equals(List.of("core", "util", "app"));
        });
        t.put("a dependency reached twice runs once", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("a", "b"));
            graph.put("a", List.of("c"));
            graph.put("b", List.of("c"));
            return Main.executionOrder(graph, "app").equals(List.of("c", "a", "b", "app"));
        });
        t.put("a dependency without an entry is treated as a leaf task", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core"));
            return Main.executionOrder(graph, "app").equals(List.of("core", "app"));
        });
        t.put("a task with no dependencies runs on its own", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of());
            return Main.executionOrder(graph, "app").equals(List.of("app"))
                    && Main.executionOrder(new LinkedHashMap<>(), "app").equals(List.of("app"))
                    && Main.executionOrder(null, "app").equals(List.of("app"));
        });
        t.put("a cycle yields an empty list", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("b"));
            graph.put("b", List.of("a"));
            return Main.executionOrder(graph, "a").isEmpty()
                    && Main.executionOrder(graph, "b").isEmpty();
        });
        t.put("a self-cycle yields an empty list", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("a"));
            return Main.executionOrder(graph, "a").isEmpty();
        });
        t.put("a cycle elsewhere in the graph also yields an empty list", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("app", List.of("core"));
            graph.put("x", List.of("y"));
            graph.put("y", List.of("x"));
            return Main.executionOrder(graph, "app").isEmpty()
                    && Main.executionOrder(graph, "core").isEmpty();
        });
        t.put("null tasks and null entries are ignored", () ->
                Main.executionOrder(new LinkedHashMap<>(), null).isEmpty()
                        && Main.executionOrder(null, null).isEmpty());
        return t;
    }
}
