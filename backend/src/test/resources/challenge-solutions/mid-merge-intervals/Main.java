import java.util.*;

public class Main {
    public static List<int[]> merge(List<int[]> intervals) {
        List<int[]> merged = new ArrayList<>();
        if (intervals == null || intervals.isEmpty()) {
            return merged;
        }
        List<int[]> sorted = new ArrayList<>();
        for (int[] interval : intervals) {
            if (interval != null && interval.length >= 2) {
                sorted.add(new int[]{interval[0], interval[1]});
            }
        }
        sorted.sort(Comparator.comparingInt(interval -> interval[0]));
        for (int[] interval : sorted) {
            if (!merged.isEmpty() && interval[0] <= merged.get(merged.size() - 1)[1]) {
                int[] current = merged.get(merged.size() - 1);
                current[1] = Math.max(current[1], interval[1]);
            } else {
                merged.add(new int[]{interval[0], interval[1]});
            }
        }
        return merged;
    }
}
