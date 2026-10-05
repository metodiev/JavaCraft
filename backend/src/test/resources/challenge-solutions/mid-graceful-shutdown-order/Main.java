import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class Main {
    private static final List<String> PHASES = List.of("stop-accepting", "drain", "pools", "connections");

    public static List<String> shutdownOrder(List<String> resources) {
        List<String> order = new ArrayList<>();
        if (resources == null) {
            return order;
        }
        Set<String> present = new LinkedHashSet<>();
        for (String resource : resources) {
            if (resource != null && PHASES.contains(resource)) {
                present.add(resource);
            }
        }
        for (String phase : PHASES) {
            if (present.contains(phase)) {
                order.add(phase);
            }
        }
        return order;
    }
}
