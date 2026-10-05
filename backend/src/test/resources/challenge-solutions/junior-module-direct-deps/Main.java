import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

public class Main {
    public static List<String> directDependencies(Map<String, List<String>> graph, String module) {
        List<String> result = new ArrayList<>();
        if (graph == null || module == null) {
            return result;
        }
        List<String> dependencies = graph.get(module);
        if (dependencies == null) {
            return result;
        }
        TreeSet<String> sorted = new TreeSet<>();
        for (String dependency : dependencies) {
            if (dependency != null) {
                sorted.add(dependency);
            }
        }
        result.addAll(sorted);
        return result;
    }
}
