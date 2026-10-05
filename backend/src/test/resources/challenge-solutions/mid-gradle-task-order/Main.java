import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Main {
    public static List<String> executionOrder(Map<String, List<String>> dependsOn, String task) {
        List<String> order = new ArrayList<>();
        if (task == null || hasCycle(dependsOn)) {
            return order;
        }
        Set<String> visiting = new LinkedHashSet<>();
        Set<String> done = new HashSet<>();
        if (!visit(dependsOn, task, visiting, done, order)) {
            return new ArrayList<>();
        }
        return order;
    }

    private static boolean hasCycle(Map<String, List<String>> dependsOn) {
        if (dependsOn == null) {
            return false;
        }
        Set<String> visited = new HashSet<>();
        Set<String> done = new HashSet<>();
        for (String node : dependsOn.keySet()) {
            if (node != null && !done.contains(node) && !check(dependsOn, node, visited, done)) {
                return true;
            }
        }
        return false;
    }

    private static boolean check(Map<String, List<String>> dependsOn, String task, Set<String> visited,
            Set<String> done) {
        if (!visited.add(task)) {
            return false;
        }
        List<String> dependencies = dependsOn.get(task);
        if (dependencies != null) {
            for (String dependency : dependencies) {
                if (dependency != null && !done.contains(dependency) && !check(dependsOn, dependency, visited, done)) {
                    return false;
                }
            }
        }
        visited.remove(task);
        done.add(task);
        return true;
    }

    private static boolean visit(Map<String, List<String>> dependsOn, String task, Set<String> visiting,
            Set<String> done, List<String> order) {
        if (done.contains(task)) {
            return true;
        }
        if (!visiting.add(task)) {
            return false;
        }
        List<String> dependencies = dependsOn == null ? null : dependsOn.get(task);
        if (dependencies != null) {
            for (String dependency : dependencies) {
                if (dependency != null && !visit(dependsOn, dependency, visiting, done, order)) {
                    return false;
                }
            }
        }
        visiting.remove(task);
        done.add(task);
        order.add(task);
        return true;
    }
}
