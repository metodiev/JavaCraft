import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> claims, long nowEpochSeconds, String expectedAudience) {
        // TODO: report "missing <claim>" for absent sub/exp/aud claims and
        // "expired" or "audience mismatch" for the values that fail validation.
        return List.of();
    }
}
