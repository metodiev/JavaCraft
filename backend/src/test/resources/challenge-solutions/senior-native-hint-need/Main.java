import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    private static final String[] METADATA = {"reflect-config.json", "resource-config.json", "proxy-config.json"};
    private static final String[] PREFIXES = {"reflection", "resource", "proxy"};

    public static List<String> requiredHints(List<String> codePatterns) {
        boolean[] needed = new boolean[PREFIXES.length];
        if (codePatterns != null) {
            for (String pattern : codePatterns) {
                if (pattern == null || pattern.isBlank()) {
                    continue;
                }
                String normalized = pattern.trim().toLowerCase(Locale.ROOT);
                for (int i = 0; i < PREFIXES.length; i++) {
                    if (normalized.startsWith(PREFIXES[i] + ":")) {
                        needed[i] = true;
                    }
                }
            }
        }
        List<String> result = new ArrayList<>();
        for (int i = 0; i < METADATA.length; i++) {
            if (needed[i]) {
                result.add(METADATA[i]);
            }
        }
        return result;
    }
}
