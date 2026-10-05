import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> claims, long nowEpochSeconds, String expectedAudience) {
        List<String> found = new ArrayList<>();
        boolean hasSub = claims != null && claims.get("sub") != null;
        boolean hasExp = claims != null && expiry(claims.get("exp")) != null;
        boolean hasAud = claims != null && claims.get("aud") != null;
        if (!hasSub) {
            found.add("missing sub");
        }
        if (!hasExp) {
            found.add("missing exp");
        }
        if (!hasAud) {
            found.add("missing aud");
        }
        if (hasExp && expiry(claims.get("exp")) <= nowEpochSeconds) {
            found.add("expired");
        }
        if (hasAud && expectedAudience != null && !expectedAudience.isBlank()
                && !String.valueOf(claims.get("aud")).equals(expectedAudience)) {
            found.add("audience mismatch");
        }
        return found;
    }

    private static Long expiry(Object value) {
        if (value instanceof Long parsed) {
            return parsed;
        }
        if (value instanceof Integer parsed) {
            return parsed.longValue();
        }
        return null;
    }
}
