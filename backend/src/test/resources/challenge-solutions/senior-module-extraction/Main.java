import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static List<String> extractionOrder(Map<String, Set<String>> moduleDeps) {
        List<String> order = new ArrayList<>();
        if (moduleDeps == null) {
            return order;
        }
        Set<String> remaining = new TreeSet<>(moduleDeps.keySet());
        while (!remaining.isEmpty()) {
            List<String> ready = new ArrayList<>();
            for (String module : remaining) {
                boolean blocked = false;
                for (String dependency : moduleDeps.getOrDefault(module, Set.of())) {
                    if (remaining.contains(dependency)) {
                        blocked = true;
                        break;
                    }
                }
                if (!blocked) {
                    ready.add(module);
                }
            }
            if (ready.isEmpty()) {
                return new ArrayList<>();
            }
            order.addAll(ready);
            remaining.removeAll(ready);
        }
        return order;
    }
}
