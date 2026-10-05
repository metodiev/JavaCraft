import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.regex.Pattern;

public class Main {
    private static final Pattern[] CACHE_HOSTILE = {
            Pattern.compile("\\bProject\\b"),
            Pattern.compile("\\bproject\\s*\\."),
            Pattern.compile("\\bgetProject\\s*\\("),
            Pattern.compile("\\bSystem\\s*\\.\\s*getenv\\b")
    };

    public static List<String> violations(List<String> taskLines) {
        TreeSet<String> report = new TreeSet<>();
        if (taskLines != null) {
            for (String line : taskLines) {
                if (line == null || line.trim().isEmpty()) {
                    continue;
                }
                String trimmed = line.trim();
                for (Pattern pattern : CACHE_HOSTILE) {
                    if (pattern.matcher(trimmed).find()) {
                        report.add(trimmed);
                        break;
                    }
                }
            }
        }
        return new ArrayList<>(report);
    }
}
