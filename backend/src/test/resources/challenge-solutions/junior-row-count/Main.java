import java.util.List;

public class Main {
    public static int countMatching(List<Integer> values, int threshold, boolean inclusive) {
        if (values == null) {
            return 0;
        }
        int count = 0;
        for (Integer value : values) {
            if (value != null && (inclusive ? value >= threshold : value > threshold)) {
                count++;
            }
        }
        return count;
    }
}
