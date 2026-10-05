import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Locale;
import java.util.Set;

public class Main {
    private static final Set<String> SAFE_METHODS = Set.of("GET", "HEAD", "OPTIONS", "TRACE");

    public static boolean valid(String sessionToken, String requestToken, String method) {
        if (method != null && SAFE_METHODS.contains(method.toUpperCase(Locale.ROOT))) {
            return true;
        }
        if (sessionToken == null || requestToken == null || sessionToken.isBlank() || requestToken.isBlank()) {
            return false;
        }
        return MessageDigest.isEqual(
                sessionToken.getBytes(StandardCharsets.UTF_8),
                requestToken.getBytes(StandardCharsets.UTF_8));
    }
}
