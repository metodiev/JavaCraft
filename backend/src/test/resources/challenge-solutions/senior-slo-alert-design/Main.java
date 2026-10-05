import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> alert(String sli, double target,
                                            int fastWindowMinutes, int slowWindowMinutes) {
        if (sli == null || sli.isBlank()) {
            throw new IllegalArgumentException("sli must not be blank");
        }
        if (!(target > 0 && target < 1)) {
            throw new IllegalArgumentException("target must be strictly between 0 and 1");
        }
        if (fastWindowMinutes <= 0 || slowWindowMinutes <= 0 || fastWindowMinutes >= slowWindowMinutes) {
            throw new IllegalArgumentException("windows must satisfy 0 < fast < slow");
        }
        double factor = slowWindowMinutes <= 60 ? 14.4 : slowWindowMinutes <= 360 ? 6.0 : 1.0;
        Map<String, Object> definition = new LinkedHashMap<>();
        definition.put("sli", sli);
        definition.put("budget", 1 - target);
        definition.put("fastWindowSeconds", fastWindowMinutes * 60);
        definition.put("slowWindowSeconds", slowWindowMinutes * 60);
        definition.put("burnRateFactor", factor);
        definition.put("condition", "burnRate > " + factor + " over " + fastWindowMinutes
                + "m and " + slowWindowMinutes + "m");
        return definition;
    }
}
