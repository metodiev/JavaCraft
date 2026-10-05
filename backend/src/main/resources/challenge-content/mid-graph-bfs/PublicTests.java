import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("visits level by level with sorted neighbours", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("b", "c"));
            graph.put("b", List.of("d"));
            graph.put("c", List.of("d"));
            graph.put("d", List.of());
            return Main.bfs(graph, "a").equals(List.of("a", "b", "c", "d"));
        });
        t.put("order between siblings follows natural sorting", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("s", List.of("z", "a", "m"));
            return Main.bfs(graph, "s").equals(List.of("s", "a", "m", "z"));
        });
        t.put("survives a cycle", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("b"));
            graph.put("b", List.of("a"));
            return Main.bfs(graph, "a").equals(List.of("a", "b"));
        });
        t.put("returns only the start for an isolated node", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("lonely", List.of());
            return Main.bfs(graph, "lonely").equals(List.of("lonely"));
        });
        t.put("unknown start yields an empty list", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", List.of("b"));
            return Main.bfs(graph, "missing").isEmpty() && Main.bfs(graph, null).isEmpty();
        });
        t.put("null or empty graph yields an empty list", () ->
                Main.bfs(null, "a").isEmpty() && Main.bfs(new LinkedHashMap<>(), "a").isEmpty());
        t.put("ignores null neighbours", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            graph.put("a", Arrays.asList(null, "b"));
            graph.put("b", List.of());
            return Main.bfs(graph, "a").equals(List.of("a", "b"));
        });
        t.put("handles a larger chain within the budget", () -> {
            Map<String, List<String>> graph = new LinkedHashMap<>();
            for (int i = 0; i < 300; i++) {
                graph.put("n" + i, List.of("n" + (i + 1)));
            }
            graph.put("n300", List.of());
            List<String> order = Main.bfs(graph, "n0");
            return order.size() == 301 && order.get(0).equals("n0") && order.get(300).equals("n300");
        });
        return t;
    }
}
