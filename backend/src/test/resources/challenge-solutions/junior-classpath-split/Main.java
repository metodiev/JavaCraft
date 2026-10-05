import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> classpathEntries(String path, boolean windows) {
        List<String> entries = new ArrayList<>();
        if (path == null || path.isEmpty()) {
            return entries;
        }
        char separator = windows ? ';' : ':';
        int start = 0;
        for (int i = 0; i <= path.length(); i++) {
            if (i == path.length() || path.charAt(i) == separator) {
                String entry = path.substring(start, i);
                if (!entry.isEmpty()) {
                    entries.add(entry);
                }
                start = i + 1;
            }
        }
        return entries;
    }
}
