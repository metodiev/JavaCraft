import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Main {
    public static List<String> sequence(List<String> items, Map<String, Set<String>> blockedBy) {
        // TODO: order items so blockers come first, and return an empty list on cycles
        return items == null ? List.of() : new ArrayList<>(items);
    }
}
