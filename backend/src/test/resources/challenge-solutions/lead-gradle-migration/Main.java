import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

public class Main {
    public static List<String> migrationOrder(Map<String, List<String>> moduleDeps) {
        TreeMap<String, Set<String>> graph = new TreeMap<>();
        if (moduleDeps != null) {
            for (Map.Entry<String, List<String>> entry : moduleDeps.entrySet()) {
                String module = entry.getKey();
                if (module == null || module.trim().isEmpty()) {
                    continue;
                }
                Set<String> dependencies = new TreeSet<>();
                if (entry.getValue() != null) {
                    for (String dependency : entry.getValue()) {
                        if (dependency != null && !dependency.trim().isEmpty()) {
                            dependencies.add(dependency.trim());
                            graph.computeIfAbsent(dependency.trim(), key -> new TreeSet<>());
                        }
                    }
                }
                graph.computeIfAbsent(module, key -> new TreeSet<>()).addAll(dependencies);
            }
        }
        List<String> order = new ArrayList<>();
        Set<String> visiting = new LinkedHashSet<>();
        Set<String> migrated = new TreeSet<>();
        for (String module : new ArrayList<>(graph.keySet())) {
            if (!visit(graph, module, visiting, migrated, order)) {
                return new ArrayList<>();
            }
        }
        if (order.size() != graph.size()) {
            return new ArrayList<>();
        }
        return order;
    }

    private static boolean visit(TreeMap<String, Set<String>> graph, String module, Set<String> visiting,
            Set<String> migrated, List<String> order) {
        if (migrated.contains(module)) {
            return true;
        }
        if (!visiting.add(module)) {
            return false;
        }
        Set<String> dependencies = graph.get(module);
        if (dependencies != null) {
            List<String> sorted = new ArrayList<>(dependencies);
            Collections.sort(sorted);
            for (String dependency : sorted) {
                if (!visit(graph, dependency, visiting, migrated, order)) {
                    return false;
                }
            }
        }
        visiting.remove(module);
        migrated.add(module);
        order.add(module);
        return true;
    }
}
