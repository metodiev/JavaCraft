import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> securityContext) {
        if (securityContext == null) {
            return List.of("runAsNonRoot", "privileged", "readOnlyRootFilesystem");
        }
        List<String> result = new ArrayList<>();
        if (!Boolean.TRUE.equals(securityContext.get("runAsNonRoot"))) {
            Object runAsUser = securityContext.get("runAsUser");
            if (runAsUser == null || ((Number) runAsUser).longValue() <= 0) {
                result.add("runAsNonRoot");
            }
        }
        if (!Boolean.FALSE.equals(securityContext.get("privileged"))) {
            result.add("privileged");
        }
        if (!Boolean.TRUE.equals(securityContext.get("readOnlyRootFilesystem"))) {
            result.add("readOnlyRootFilesystem");
        }
        return result;
    }
}
