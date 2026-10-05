import java.util.HashMap;
import java.util.Map;

public class Main {
    public static Map<String, Integer> mergeSums(Map<String, Integer> left, Map<String, Integer> right) {
        Map<String, Integer> result = new HashMap<>();
        if (left != null) {
            result.putAll(left);
        }
        if (right != null) {
            for (Map.Entry<String, Integer> entry : right.entrySet()) {
                result.merge(entry.getKey(), entry.getValue(), Integer::sum);
            }
        }
        return result;
    }
}
