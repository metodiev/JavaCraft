import java.util.List;
import java.util.Map;

public class Main {
    public static String gate(List<Map<String, Object>> findings, int severityThreshold) {
        // TODO: FAIL on reachable findings at or above the threshold, WARN on other findings, PASS when clean
        return "WARN";
    }
}
