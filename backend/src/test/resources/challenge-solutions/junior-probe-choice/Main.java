import java.util.Locale;

public class Main {
    public static String probeFor(String purpose) {
        if (purpose == null) {
            return "NONE";
        }
        String text = purpose.toLowerCase(Locale.ROOT);
        if (text.isBlank()) {
            return "NONE";
        }
        if (text.contains("startup") || text.contains("boot")) {
            return "STARTUP";
        }
        if (text.contains("readiness") || text.contains("ready") || text.contains("traffic")) {
            return "READINESS";
        }
        if (text.contains("liveness") || text.contains("alive") || text.contains("restart")
                || text.contains("deadlock")) {
            return "LIVENESS";
        }
        return "NONE";
    }
}
