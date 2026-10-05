import java.util.List;
import java.util.Map;

public class Main {
    public static String gate(List<Map<String, Object>> findings, int severityThreshold) {
        if (severityThreshold < 1 || severityThreshold > 10) {
            throw new IllegalArgumentException("severity threshold must be between 1 and 10");
        }
        if (findings == null || findings.isEmpty()) {
            return "PASS";
        }
        for (Map<String, Object> finding : findings) {
            if (finding == null) {
                continue;
            }
            boolean reachable = Boolean.TRUE.equals(finding.get("reachable"));
            int severity = finding.get("severity") instanceof Number number ? number.intValue() : 0;
            if (reachable && severity >= severityThreshold) {
                return "FAIL";
            }
        }
        return "WARN";
    }
}
