import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> headers(boolean httpsOnly) {
        Map<String, String> headers = new LinkedHashMap<>();
        // TODO: add the documented hardening headers; Strict-Transport-Security only when httpsOnly
        headers.put("Strict-Transport-Security", "max-age=31536000");
        return headers;
    }
}
