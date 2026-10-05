import java.util.Map;

public class Main {
    public static Map<String, Integer> estimate(int optimisticDays, double uncertaintyFactor) {
        // TODO: best, likely and worst case with the documented bounds
        return Map.of("best", optimisticDays, "likely", optimisticDays, "worst", optimisticDays);
    }
}
