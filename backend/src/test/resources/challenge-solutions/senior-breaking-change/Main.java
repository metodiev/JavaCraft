import java.util.*;

public class Main {
    private static final List<String> RANKS = List.of("byte", "short", "int", "long", "float", "double");

    public static List<String> breakingChanges(Map<String, String> before, Map<String, String> after) {
        if (before == null || after == null) {
            throw new IllegalArgumentException("both schemas are required");
        }
        List<String> changes = new ArrayList<>();
        for (Map.Entry<String, String> entry : before.entrySet()) {
            String field = entry.getKey();
            String oldType = entry.getValue();
            if (!after.containsKey(field)) {
                changes.add("removed: " + field + " (" + oldType + ")");
                continue;
            }
            String newType = after.get(field);
            if (oldType.equals(newType)) {
                continue;
            }
            int oldRank = rank(oldType);
            int newRank = rank(newType);
            if (oldRank >= 0 && newRank >= 0) {
                if (newRank < oldRank) {
                    changes.add("narrowed: " + field + " (" + oldType + " -> " + newType + ")");
                }
                continue;
            }
            changes.add("changed: " + field + " (" + oldType + " -> " + newType + ")");
        }
        for (Map.Entry<String, String> entry : after.entrySet()) {
            String field = entry.getKey();
            if (!before.containsKey(field) && entry.getValue() != null && entry.getValue().endsWith("!")) {
                changes.add("new required: " + field + " (" + entry.getValue() + ")");
            }
        }
        Collections.sort(changes);
        return changes;
    }

    private static int rank(String descriptor) {
        String base = descriptor.endsWith("!") ? descriptor.substring(0, descriptor.length() - 1) : descriptor;
        return RANKS.indexOf(base);
    }
}
