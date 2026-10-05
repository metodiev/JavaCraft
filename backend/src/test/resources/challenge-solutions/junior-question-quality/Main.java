import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> missingParts(String question) {
        List<String> out = new ArrayList<>();
        boolean context = hasPart(question, "context:");
        boolean tried = hasPart(question, "i tried");
        boolean repro = hasPart(question, "minimal example:");
        if (!context) {
            out.add("missing context");
        }
        if (!tried) {
            out.add("missing attempted steps");
        }
        if (!repro) {
            out.add("missing minimal reproduction");
        }
        return out;
    }

    private static boolean hasPart(String question, String marker) {
        if (question == null) {
            return false;
        }
        String lower = question.toLowerCase(Locale.ROOT);
        int from = 0;
        while (true) {
            int idx = lower.indexOf(marker, from);
            if (idx < 0) {
                return false;
            }
            int end = question.length();
            int next = lower.indexOf("context:", idx + marker.length());
            int tried = lower.indexOf("i tried", idx + marker.length());
            int repro = lower.indexOf("minimal example:", idx + marker.length());
            if (next >= 0) {
                end = Math.min(end, next);
            }
            if (tried >= 0) {
                end = Math.min(end, tried);
            }
            if (repro >= 0) {
                end = Math.min(end, repro);
            }
            if (!question.substring(idx + marker.length(), end).isBlank()) {
                return true;
            }
            from = idx + marker.length();
        }
    }
}
