import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static List<String> sequence(List<String> items, Map<String, Set<String>> blockedBy) {
        List<String> result = new ArrayList<>();
        if (items == null) {
            return result;
        }
        Set<String> all = new TreeSet<>();
        for (String item : items) {
            if (item != null) {
                all.add(item);
            }
        }
        if (all.isEmpty()) {
            return result;
        }
        Map<String, Set<String>> blockers = new HashMap<>();
        Map<String, List<String>> dependents = new HashMap<>();
        for (String item : all) {
            Set<String> prerequisites = new TreeSet<>();
            Set<String> given = blockedBy == null ? null : blockedBy.get(item);
            if (given != null) {
                if (given.contains(item)) {
                    return result;
                }
                for (String blocker : given) {
                    if (blocker != null && all.contains(blocker)) {
                        prerequisites.add(blocker);
                    }
                }
            }
            blockers.put(item, prerequisites);
            for (String prerequisite : prerequisites) {
                dependents.computeIfAbsent(prerequisite, key -> new ArrayList<>()).add(item);
            }
        }
        PriorityQueue<String> ready = new PriorityQueue<>();
        for (String item : all) {
            if (blockers.get(item).isEmpty()) {
                ready.add(item);
            }
        }
        while (!ready.isEmpty()) {
            String item = ready.poll();
            result.add(item);
            for (String dependent : dependents.getOrDefault(item, List.of())) {
                Set<String> remaining = blockers.get(dependent);
                remaining.remove(item);
                if (remaining.isEmpty()) {
                    ready.add(dependent);
                }
            }
        }
        if (result.size() != all.size()) {
            return new ArrayList<>();
        }
        return result;
    }
}
