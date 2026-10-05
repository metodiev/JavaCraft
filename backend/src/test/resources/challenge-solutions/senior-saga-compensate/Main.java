import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Main {
    private static final String AUDIT_PREFIX = "audit-";

    public static List<String> compensate(List<String> completed, String failedStep) {
        List<String> result = new ArrayList<>();
        if (completed == null) {
            return result;
        }
        Set<String> compensated = new HashSet<>();
        for (int i = completed.size() - 1; i >= 0; i--) {
            String step = completed.get(i);
            if (step == null || step.startsWith(AUDIT_PREFIX) || step.equals(failedStep)) {
                continue;
            }
            if (compensated.add(step)) {
                result.add(step);
            }
        }
        return result;
    }
}
