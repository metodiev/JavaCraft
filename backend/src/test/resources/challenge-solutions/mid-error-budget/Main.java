import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> budget(double target, long totalRequests, long failedRequests) {
        if (Double.isNaN(target) || Double.isInfinite(target) || target <= 0.0 || target >= 1.0) {
            throw new IllegalArgumentException("target must be strictly between 0 and 1");
        }
        if (totalRequests < 0) {
            throw new IllegalArgumentException("totalRequests must not be negative");
        }
        if (failedRequests < 0 || failedRequests > totalRequests) {
            throw new IllegalArgumentException("failedRequests must be within 0..totalRequests");
        }
        double allowedFraction = 1.0 - target;
        long allowedFailures = (long) Math.floor(totalRequests * allowedFraction);
        double consumed;
        if (allowedFailures == 0) {
            consumed = failedRequests == 0 ? 0.0 : 1.0;
        } else {
            consumed = Math.min(1.0, failedRequests / (double) allowedFailures);
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("allowedFraction", allowedFraction);
        result.put("consumedFraction", consumed);
        result.put("remainingFraction", 1.0 - consumed);
        result.put("exhausted", consumed >= 1.0);
        return result;
    }
}
