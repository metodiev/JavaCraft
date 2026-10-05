import java.util.List;
import java.util.Locale;

public class Main {
    public static String gate(List<String> severities, int blockerThreshold) {
        if (severities == null) {
            return "WARN";
        }
        boolean malformed = false;
        boolean warn = false;
        int blockers = 0;
        for (String severity : severities) {
            if (severity == null) {
                malformed = true;
                continue;
            }
            switch (severity.strip().toLowerCase(Locale.ROOT)) {
                case "critical", "vulnerability":
                    return "FAIL";
                case "blocker":
                    blockers++;
                    break;
                case "minor", "info":
                    warn = true;
                    break;
                default:
                    malformed = true;
            }
        }
        if (blockers > blockerThreshold) {
            return "FAIL";
        }
        return (warn || malformed || blockers > 0) ? "WARN" : "PASS";
    }
}
