import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("parses a full coordinate in order", () -> Arrays.equals(
                Main.parse("com.example:demo:1.0.0"), new String[] {"com.example", "demo", "1.0.0"}));
        t.put("defaults a missing version to an empty string", () -> Arrays.equals(
                Main.parse("com.example:demo"), new String[] {"com.example", "demo", ""}));
        t.put("defaults a missing artifact and version to empty strings", () -> Arrays.equals(
                Main.parse("com.example"), new String[] {"com.example", "", ""}));
        t.put("trims every segment", () -> Arrays.equals(
                Main.parse("  com.example : demo : 1.0 "), new String[] {"com.example", "demo", "1.0"}));
        t.put("rejects a coordinate with too many segments", () -> rejects("g:a:1.0:extra"));
        t.put("rejects an empty middle segment", () -> rejects("com.example::1.0"));
        t.put("rejects a trailing colon", () -> rejects("com.example:demo:"));
        t.put("rejects null and blank coordinates", () -> rejects(null) && rejects("   "));
        return t;
    }

    private static boolean rejects(String coordinate) {
        try {
            Main.parse(coordinate);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
