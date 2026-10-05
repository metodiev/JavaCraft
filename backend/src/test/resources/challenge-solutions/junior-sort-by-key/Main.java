import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> byLength(List<String> values) {
        if (values == null || values.isEmpty()) {
            return new ArrayList<>();
        }
        List<String> sorted = new ArrayList<>(values);
        sorted.sort((left, right) -> {
            if (left == null && right == null) {
                return 0;
            }
            if (left == null) {
                return 1;
            }
            if (right == null) {
                return -1;
            }
            return Integer.compare(left.length(), right.length());
        });
        return sorted;
    }
}
