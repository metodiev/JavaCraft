import java.util.Locale;

public class Main {
    private static final String[] CAUSES = {"cpu", "memory", "heap", "disk", "thread", "gc"};

    public static String condition(String metric, double threshold, String window) {
        if (metric == null || metric.isBlank() || window == null || window.isBlank()) {
            throw new IllegalArgumentException("metric and window must not be blank");
        }
        if (!Double.isFinite(threshold)) {
            throw new IllegalArgumentException("threshold must be finite");
        }
        String name = metric.trim();
        String lower = name.toLowerCase(Locale.ROOT);
        for (String cause : CAUSES) {
            if (lower.contains(cause)) {
                throw new IllegalArgumentException("cause-based metric cannot page: " + name);
            }
        }
        return name + " > " + threshold + " for " + window.trim();
    }
}
