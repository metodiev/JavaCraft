import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> transactionalOperations(List<String> steps) {
        List<String> result = new ArrayList<>();
        if (steps == null) {
            return result;
        }
        for (String step : steps) {
            if (step == null || step.isBlank()) {
                continue;
            }
            String normalized = step.toLowerCase(Locale.ROOT);
            if (containsAny(normalized, "read", "load", "select") && containsAny(normalized, "write", "insert", "update", "delete")) {
                result.add(step);
            }
        }
        return result;
    }

    private static boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
