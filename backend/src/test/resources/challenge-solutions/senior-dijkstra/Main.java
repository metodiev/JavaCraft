import java.util.*;

public class Main {
    public static Map<String, Integer> shortestPaths(Map<String, Map<String, Integer>> graph, String source) {
        Map<String, Integer> distances = new LinkedHashMap<>();
        if (graph == null || source == null || !graph.containsKey(source)) {
            return distances;
        }
        Map<String, Integer> best = new HashMap<>();
        PriorityQueue<String> queue = new PriorityQueue<>(Comparator.comparingInt(best::get));
        best.put(source, 0);
        queue.add(source);
        while (!queue.isEmpty()) {
            String node = queue.poll();
            int distance = best.get(node);
            Map<String, Integer> edges = graph.get(node);
            if (edges == null) {
                continue;
            }
            for (Map.Entry<String, Integer> edge : edges.entrySet()) {
                String target = edge.getKey();
                Integer weight = edge.getValue();
                if (target == null || weight == null || weight <= 0) {
                    continue;
                }
                int candidate = distance + weight;
                Integer known = best.get(target);
                if (known == null || candidate < known) {
                    best.put(target, candidate);
                    queue.add(target);
                }
            }
        }
        for (Map.Entry<String, Integer> entry : best.entrySet()) {
            distances.put(entry.getKey(), entry.getValue());
        }
        return distances;
    }
}
