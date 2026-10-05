import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> problems(String name) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("metric name must not be blank");
        }
        boolean uppercase = false;
        boolean space = false;
        boolean other = false;
        for (int i = 0; i < name.length(); i++) {
            char c = name.charAt(i);
            if (c >= 'A' && c <= 'Z') {
                uppercase = true;
            } else if (Character.isWhitespace(c)) {
                space = true;
            } else if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '.')) {
                other = true;
            }
        }
        boolean emptySegment = name.startsWith(".") || name.endsWith(".") || name.contains("..");
        List<String> problems = new ArrayList<>();
        if (uppercase) {
            problems.add("uppercase");
        }
        if (space) {
            problems.add("space");
        }
        if (other) {
            problems.add("other-character");
        }
        if (emptySegment) {
            problems.add("empty-segment");
        }
        return problems;
    }
}
