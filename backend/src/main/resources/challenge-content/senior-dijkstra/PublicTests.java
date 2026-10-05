import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("finds the shortest route through a weighted graph", () -> {
            Map<String, Map<String, Integer>> graph = new LinkedHashMap<>();
            graph.put("a", Map.of("b", 1, "c", 4));
            graph.put("b", Map.of("c", 2, "d", 5));
            graph.put("c", Map.of("d", 1));
            graph.put("d", Map.of());
            Map<String, Integer> result = Main.shortestPaths(graph, "a");
            return result.equals(Map.of("a", 0, "b", 1, "c", 3, "d", 4));
        });
        t.put("prefers a longer edge count when the total weight is smaller", () -> {
            Map<String, Map<String, Integer>> graph = new LinkedHashMap<>();
            graph.put("s", Map.of("x", 10, "y", 1));
            graph.put("y", Map.of("x", 1));
            graph.put("x", Map.of());
            return Main.shortestPaths(graph, "s").get("x") == 2;
        });
        t.put("omits unreachable nodes", () -> {
            Map<String, Map<String, Integer>> graph = new LinkedHashMap<>();
            graph.put("a", Map.of("b", 2));
            graph.put("b", Map.of());
            graph.put("island", Map.of());
            Map<String, Integer> result = Main.shortestPaths(graph, "a");
            return result.equals(Map.of("a", 0, "b", 2)) && !result.containsKey("island");
        });
        t.put("the source is included with distance zero", () ->
                Main.shortestPaths(Map.of("a", Map.of()), "a").equals(Map.of("a", 0)));
        t.put("null or unknown source yields an empty map", () -> {
            Map<String, Map<String, Integer>> graph = new LinkedHashMap<>();
            graph.put("a", Map.of("b", 1));
            return Main.shortestPaths(graph, "missing").isEmpty() && Main.shortestPaths(graph, null).isEmpty();
        });
        t.put("null or empty graph yields an empty map", () ->
                Main.shortestPaths(null, "a").isEmpty() && Main.shortestPaths(Map.of(), "a").isEmpty());
        t.put("skips null targets and non-positive weights", () -> {
            Map<String, Map<String, Integer>> graph = new LinkedHashMap<>();
            Map<String, Integer> edges = new LinkedHashMap<>();
            edges.put("b", 3);
            edges.put("c", 0);
            edges.put("d", -2);
            edges.put(null, 1);
            graph.put("a", edges);
            graph.put("b", Map.of());
            graph.put("c", Map.of());
            graph.put("d", Map.of());
            return Main.shortestPaths(graph, "a").equals(Map.of("a", 0, "b", 3));
        });
        t.put("handles a cycle without looping forever", () -> {
            Map<String, Map<String, Integer>> graph = new LinkedHashMap<>();
            graph.put("a", Map.of("b", 1));
            graph.put("b", Map.of("a", 1, "c", 1));
            graph.put("c", Map.of("a", 1));
            return Main.shortestPaths(graph, "a").equals(Map.of("a", 0, "b", 1, "c", 2));
        });
        return t;
    }
}
