import java.util.Map;

public class Main {
    public static int portFrom(Map<String, String> environment, int fallback) {
        // TODO: bind app.port with relaxed name matching, validate 1..65535 and fall back
        return fallback;
    }
}
