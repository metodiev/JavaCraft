import java.util.HashMap;
import java.util.Map;

public class Main {
    public static int[] twoSum(int[] values, int target) {
        if (values == null || values.length < 2) {
            return new int[0];
        }
        Map<Integer, Integer> seen = new HashMap<>();
        for (int index = 0; index < values.length; index++) {
            int needed = target - values[index];
            Integer earlier = seen.get(needed);
            if (earlier != null) {
                return new int[]{earlier, index};
            }
            seen.putIfAbsent(values[index], index);
        }
        return new int[0];
    }
}
