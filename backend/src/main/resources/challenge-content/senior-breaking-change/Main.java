import java.util.*;

public class Main {
    public static List<String> breakingChanges(Map<String, String> before, Map<String, String> after) {
        // TODO: report removed fields, narrowed numeric types and new required fields
        List<String> changes = new ArrayList<>();
        if (before == null || after == null) {
            return changes;
        }
        for (String field : before.keySet()) {
            if (!after.containsKey(field)) {
                changes.add(field);
            }
        }
        return changes;
    }
}
