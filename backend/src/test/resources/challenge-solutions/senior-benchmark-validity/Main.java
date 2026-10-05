import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class Main {
    public static List<String> problems(Map<String, String> benchmark) {
        List<String> problems = new ArrayList<>();
        if (!isPositiveNumber(get(benchmark, "warmupIterations"))) {
            problems.add("missing warmup");
        }
        if (!isAtLeastTwo(get(benchmark, "forks"))) {
            problems.add("no forks");
        }
        if (!isTrue(get(benchmark, "blackhole"))) {
            problems.add("dead code elimination");
        }
        if (!isTrue(get(benchmark, "baseline"))) {
            problems.add("no baseline");
        }
        return problems;
    }

    private static String get(Map<String, String> benchmark, String key) {
        return benchmark == null ? null : benchmark.get(key);
    }

    private static boolean isTrue(String value) {
        return value != null && "true".equals(value.strip().toLowerCase(Locale.ROOT));
    }

    private static boolean isPositiveNumber(String value) {
        if (value == null) {
            return false;
        }
        try {
            return Double.parseDouble(value.strip()) > 0;
        } catch (NumberFormatException ex) {
            return false;
        }
    }

    private static boolean isAtLeastTwo(String value) {
        if (value == null) {
            return false;
        }
        try {
            return Double.parseDouble(value.strip()) >= 2;
        } catch (NumberFormatException ex) {
            return false;
        }
    }
}
