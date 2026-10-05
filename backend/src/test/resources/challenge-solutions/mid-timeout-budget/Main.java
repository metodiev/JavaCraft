import java.util.*;

public class Main {
    public static Map<String, Long> budget(long totalMillis, int attempts) {
        if (totalMillis < 1) {
            throw new IllegalArgumentException("total must be positive");
        }
        if (attempts < 1) {
            throw new IllegalArgumentException("attempts must be positive");
        }
        long perAttempt = totalMillis / attempts;
        long read = perAttempt / 2;
        Map<String, Long> plan = new LinkedHashMap<>();
        plan.put("budget", totalMillis);
        plan.put("connect", perAttempt - read);
        plan.put("read", read);
        return plan;
    }
}
