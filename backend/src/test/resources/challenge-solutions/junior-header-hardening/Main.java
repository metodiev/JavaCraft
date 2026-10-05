import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> headers(boolean httpsOnly) {
        Map<String, String> headers = new LinkedHashMap<>();
        headers.put("X-Content-Type-Options", "nosniff");
        headers.put("X-Frame-Options", "DENY");
        headers.put("Referrer-Policy", "no-referrer");
        headers.put("Content-Security-Policy", "default-src 'self'");
        if (httpsOnly) {
            headers.put("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        }
        return headers;
    }
}
