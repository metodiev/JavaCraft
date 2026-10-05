import java.util.Map;

public class Main {
    public static Map<String, Integer> estimate(int optimisticDays, double uncertaintyFactor) {
        if (optimisticDays < 1) {
            throw new IllegalArgumentException("optimisticDays must be at least 1");
        }
        if (uncertaintyFactor < 1.0) {
            throw new IllegalArgumentException("uncertaintyFactor must be at least 1.0");
        }
        double factor = Math.min(5.0, uncertaintyFactor);
        int likely = (int) Math.ceil(optimisticDays * factor);
        int worst = likely + (likely - optimisticDays);
        return Map.of("best", optimisticDays, "likely", likely, "worst", worst);
    }
}
