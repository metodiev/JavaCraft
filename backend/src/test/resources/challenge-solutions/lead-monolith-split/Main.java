import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static List<String> splitOrder(Map<String, Set<String>> coupling) {
        List<String> result = new ArrayList<>();
        if (coupling == null || coupling.isEmpty()) {
            return result;
        }
        Map<String, Set<String>> dependencies = new HashMap<>();
        Set<String> modules = new TreeSet<>();
        for (Map.Entry<String, Set<String>> entry : coupling.entrySet()) {
            String module = entry.getKey();
            if (module == null) {
                continue;
            }
            modules.add(module);
            Set<String> deps = new TreeSet<>();
            if (entry.getValue() != null) {
                for (String dependency : entry.getValue()) {
                    if (dependency != null) {
                        deps.add(dependency);
                        modules.add(dependency);
                    }
                }
            }
            dependencies.put(module, deps);
        }
        Set<String> remaining = new TreeSet<>(modules);
        while (!remaining.isEmpty()) {
            List<String> extractable = new ArrayList<>();
            for (String module : remaining) {
                boolean ready = true;
                for (String dependency : dependencies.getOrDefault(module, Set.of())) {
                    if (remaining.contains(dependency)) {
                        ready = false;
                        break;
                    }
                }
                if (ready) {
                    extractable.add(module);
                }
            }
            if (extractable.isEmpty()) {
                return new ArrayList<>();
            }
            extractable.sort(Comparator
                    .comparingInt((String module) -> degree(module, remaining, dependencies))
                    .thenComparing(Comparator.naturalOrder()));
            String chosen = extractable.get(0);
            result.add(chosen);
            remaining.remove(chosen);
        }
        return result;
    }

    private static int degree(String module, Set<String> remaining, Map<String, Set<String>> dependencies) {
        int degree = 0;
        for (String dependency : dependencies.getOrDefault(module, Set.of())) {
            if (!dependency.equals(module) && remaining.contains(dependency)) {
                degree++;
            }
        }
        for (String other : remaining) {
            if (!other.equals(module) && dependencies.getOrDefault(other, Set.of()).contains(module)) {
                degree++;
            }
        }
        return degree;
    }
}
