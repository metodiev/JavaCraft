import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> executionOrder(Map<String, Integer> aspectOrders) {
        if (aspectOrders == null) {
            return List.of();
        }
        List<Map.Entry<String, Integer>> aspects = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : aspectOrders.entrySet()) {
            if (entry.getKey() != null) {
                aspects.add(Map.entry(entry.getKey(), entry.getValue() == null ? 0 : entry.getValue()));
            }
        }
        aspects.sort(Comparator.<Map.Entry<String, Integer>, Integer>comparing(Map.Entry::getValue)
                .thenComparing(Map.Entry::getKey));
        List<String> result = new ArrayList<>();
        for (Map.Entry<String, Integer> aspect : aspects) {
            result.add(aspect.getKey() + " in");
        }
        for (int i = aspects.size() - 1; i >= 0; i--) {
            result.add(aspects.get(i).getKey() + " out");
        }
        return result;
    }
}
