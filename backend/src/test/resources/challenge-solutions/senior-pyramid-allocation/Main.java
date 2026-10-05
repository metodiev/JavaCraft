import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    private static final String[] LEVELS = {"unit", "integration", "endToEnd"};

    public static Map<String, Integer> allocate(int totalTests, boolean logicHeavy, boolean ioHeavy) {
        int[] parts;
        if (logicHeavy && !ioHeavy) {
            parts = new int[] {70, 20, 10};
        } else if (ioHeavy && !logicHeavy) {
            parts = new int[] {50, 40, 10};
        } else {
            parts = new int[] {60, 30, 10};
        }
        int percentSum = 100;
        Map<String, Integer> counts = new LinkedHashMap<>();
        if (totalTests <= 0) {
            for (String level : LEVELS) {
                counts.put(level, 0);
            }
            return counts;
        }
        int[] result = new int[3];
        int assigned = 0;
        for (int i = 0; i < 3; i++) {
            result[i] = totalTests * parts[i] / percentSum;
            assigned += result[i];
        }
        Integer[] order = {0, 1, 2};
        java.util.Arrays.sort(order, (a, b) -> {
            long left = ((long) totalTests * parts[a]) % percentSum;
            long right = ((long) totalTests * parts[b]) % percentSum;
            if (left != right) {
                return Long.compare(right, left);
            }
            return Integer.compare(a, b);
        });
        for (int i = 0; i < totalTests - assigned; i++) {
            result[order[i]]++;
        }
        for (int i = 0; i < 3; i++) {
            counts.put(LEVELS[i], result[i]);
        }
        return counts;
    }
}
