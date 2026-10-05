import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("parses an exact name", () -> Main.parsePriority("LOW") == Main.Priority.LOW);
        t.put("parses a lowercase name", () -> Main.parsePriority("high") == Main.Priority.HIGH);
        t.put("parses a mixed case name", () -> Main.parsePriority("NoRmAl") == Main.Priority.NORMAL);
        t.put("trims surrounding whitespace", () -> Main.parsePriority("  high  ") == Main.Priority.HIGH);
        t.put("unknown text falls back to normal", () -> Main.parsePriority("urgent") == Main.Priority.NORMAL);
        t.put("null falls back to normal", () -> Main.parsePriority(null) == Main.Priority.NORMAL);
        t.put("blank falls back to normal", () -> Main.parsePriority("   ") == Main.Priority.NORMAL);
        return t;
    }
}
