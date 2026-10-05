import java.util.*;

public class Main {
    public static List<String> bfs(Map<String, List<String>> graph, String start) {
        List<String> order = new ArrayList<>();
        if (graph == null || start == null || !graph.containsKey(start)) {
            return order;
        }
        Set<String> visited = new HashSet<>();
        Deque<String> queue = new ArrayDeque<>();
        visited.add(start);
        queue.add(start);
        while (!queue.isEmpty()) {
            String node = queue.remove();
            order.add(node);
            List<String> neighbours = graph.get(node);
            if (neighbours == null) {
                continue;
            }
            List<String> sorted = new ArrayList<>();
            for (String neighbour : neighbours) {
                if (neighbour != null) {
                    sorted.add(neighbour);
                }
            }
            Collections.sort(sorted);
            for (String neighbour : sorted) {
                if (visited.add(neighbour)) {
                    queue.add(neighbour);
                }
            }
        }
        return order;
    }
}
