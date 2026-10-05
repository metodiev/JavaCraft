import java.util.Map;

public class Main {
    public static int portFrom(Map<String, String> environment, int fallback) {
        if (environment == null) {
            return fallback;
        }
        String raw = environment.get("app.port");
        if (raw == null) {
            raw = environment.get("APP_PORT");
        }
        if (raw == null) {
            return fallback;
        }
        try {
            int port = Integer.parseInt(raw.trim());
            return port >= 1 && port <= 65535 ? port : fallback;
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }
}
