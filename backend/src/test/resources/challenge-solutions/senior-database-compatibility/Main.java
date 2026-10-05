import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> blockers(List<String> migrations) {
        List<String> result = new ArrayList<>();
        if (migrations == null) {
            return result;
        }
        for (String migration : migrations) {
            if (migration == null || migration.isBlank()) {
                continue;
            }
            String text = migration.toUpperCase(Locale.ROOT);
            if (text.contains("DROP") || text.contains("TRUNCATE") || text.contains("RENAME")) {
                result.add(migration);
            }
        }
        return result;
    }
}
