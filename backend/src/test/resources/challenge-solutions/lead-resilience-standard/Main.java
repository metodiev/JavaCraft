import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> mandatoryPatterns(boolean callsRemoteDependency, boolean writesData, boolean userFacing) {
        List<String> patterns = new ArrayList<>();
        if (callsRemoteDependency) {
            patterns.add("timeout");
            patterns.add("circuit-breaker");
            patterns.add("bulkhead");
        }
        if (writesData) {
            patterns.add("idempotency-key");
        }
        if (userFacing) {
            patterns.add("graceful-degradation");
        }
        return patterns;
    }
}
