import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static boolean hasCycle(Map<String, List<String>> waitingFor) {
        if (waitingFor == null || waitingFor.isEmpty()) {
            return false;
        }
        Map<String, Integer> state = new HashMap<>();
        for (String thread : waitingFor.keySet()) {
            if (visit(thread, waitingFor, state)) {
                return true;
            }
        }
        return false;
    }

    private static boolean visit(String thread, Map<String, List<String>> waitingFor, Map<String, Integer> state) {
        Integer current = state.get(thread);
        if (current != null) {
            return current == 1;
        }
        state.put(thread, 1);
        List<String> edges = waitingFor.get(thread);
        if (edges != null) {
            for (String target : edges) {
                if (target != null && visit(target, waitingFor, state)) {
                    return true;
                }
            }
        }
        state.put(thread, 2);
        return false;
    }
}
