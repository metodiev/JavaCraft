import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class Main {
    private static final String[][] TABLE = {
            {"elevation of privilege", "authorise every request against least privilege roles"},
            {"information disclosure", "encrypt sensitive data and enforce least privilege access"},
            {"spoofing", "authenticate every principal before it acts"},
            {"tampering", "verify integrity of data in transit and at rest"},
            {"denial of service", "apply rate limits, quotas and timeouts"},
            {"repudiation", "record tamper-evident audit logs of privileged actions"},
    };

    public static List<String> mitigations(List<String> threats) {
        List<String> out = new ArrayList<>();
        if (threats == null) {
            return out;
        }
        Set<String> present = new LinkedHashSet<>();
        for (String threat : threats) {
            if (threat != null) {
                present.add(threat.strip().toLowerCase(Locale.ROOT));
            }
        }
        for (String[] row : TABLE) {
            if (present.contains(row[0])) {
                out.add(row[1]);
            }
        }
        return out;
    }
}
