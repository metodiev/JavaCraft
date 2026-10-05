import java.util.*;

public class Main {
    public static Map<String, Long> budget(long totalMillis, int attempts) {
        // TODO: split the total into a per-attempt connect and read budget
        Map<String, Long> plan = new LinkedHashMap<>();
        plan.put("budget", totalMillis);
        plan.put("connect", totalMillis);
        plan.put("read", totalMillis);
        return plan;
    }
}
