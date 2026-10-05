import java.util.Map;

public class Main {
    public static boolean hasFanout(Map<String, Integer> parentRows, Map<String, Integer> childRows) {
        long parents = 0;
        long joined = 0;
        if (parentRows != null) {
            for (Map.Entry<String, Integer> entry : parentRows.entrySet()) {
                int parentCount = entry.getValue() == null ? 0 : entry.getValue();
                if (parentCount <= 0) {
                    continue;
                }
                parents += parentCount;
                int childCount = 0;
                if (childRows != null && childRows.get(entry.getKey()) != null) {
                    childCount = childRows.get(entry.getKey());
                }
                joined += (long) parentCount * Math.max(1, childCount);
            }
        }
        return joined > parents;
    }
}
