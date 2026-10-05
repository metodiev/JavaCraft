import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the same name and size is a duplicate", () ->
                Main.alreadyImported("data.csv", 1024, Map.of("data.csv", 1024L)));
        t.put("the same name with a new size is not a duplicate", () ->
                !Main.alreadyImported("data.csv", 1025, Map.of("data.csv", 1024L)));
        t.put("an unknown name is not a duplicate", () ->
                !Main.alreadyImported("other.csv", 1024, Map.of("data.csv", 1024L))
                        && !Main.alreadyImported("data.csv", 1024, new HashMap<>()));
        t.put("zero-length files match by size", () ->
                Main.alreadyImported("empty.txt", 0, Map.of("empty.txt", 0L))
                        && !Main.alreadyImported("empty.txt", 1, Map.of("empty.txt", 0L)));
        t.put("names are matched exactly and case sensitively", () ->
                !Main.alreadyImported("data.csv", 1, Map.of("Data.csv", 1L)));
        t.put("a missing history cannot prove a duplicate", () -> {
            Map<String, Long> history = new HashMap<>();
            history.put("data.csv", null);
            return !Main.alreadyImported("data.csv", 0, history);
        });
        t.put("invalid arguments are rejected", () -> {
            try {
                Main.alreadyImported(null, 1, new HashMap<>());
                return false;
            } catch (IllegalArgumentException expected) {
            }
            try {
                Main.alreadyImported(" ", 1, new HashMap<>());
                return false;
            } catch (IllegalArgumentException expected) {
            }
            try {
                Main.alreadyImported("a", -1, new HashMap<>());
                return false;
            } catch (IllegalArgumentException expected) {
            }
            try {
                Main.alreadyImported("a", 1, null);
                return false;
            } catch (IllegalArgumentException expected) {
                return true;
            }
        });
        return t;
    }
}
