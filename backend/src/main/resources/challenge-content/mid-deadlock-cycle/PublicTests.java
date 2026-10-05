import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("two threads waiting on each other form a cycle", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", List.of("B"));
            graph.put("B", List.of("A"));
            return Main.hasCycle(graph);
        });
        t.put("a chain without a cycle returns false", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", List.of("B"));
            graph.put("B", List.of("C"));
            graph.put("C", List.of());
            return !Main.hasCycle(graph);
        });
        t.put("a thread waiting on itself is a cycle", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", List.of("A"));
            return Main.hasCycle(graph);
        });
        t.put("unknown targets are leaves", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", List.of("Z"));
            graph.put("B", List.of("A"));
            return !Main.hasCycle(graph);
        });
        t.put("empty and null graphs have no cycle", () -> !Main.hasCycle(Map.of()) && !Main.hasCycle(null));
        t.put("a cycle in the middle of a larger graph is found", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", List.of("B"));
            graph.put("B", List.of("C"));
            graph.put("C", List.of("D"));
            graph.put("D", List.of("B"));
            graph.put("E", List.of());
            return Main.hasCycle(graph);
        });
        t.put("duplicate edges do not break detection", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", List.of("B", "B"));
            graph.put("B", List.of("A"));
            return Main.hasCycle(graph);
        });
        t.put("null target entries are ignored", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("A", Arrays.asList(null, "B"));
            graph.put("B", List.of());
            return !Main.hasCycle(graph);
        });
        return t;
    }
}
