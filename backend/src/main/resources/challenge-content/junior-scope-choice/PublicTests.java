import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("compile-only maps to compile", () -> Main.scopeFor("compile-only").equals("compile"));
        t.put("runtime-only maps to runtime", () -> Main.scopeFor("runtime-only").equals("runtime"));
        t.put("test-only maps to test", () -> Main.scopeFor("test-only").equals("test"));
        t.put("provided-by-container maps to provided", () -> Main.scopeFor("provided-by-container").equals("provided"));
        t.put("surrounding whitespace is trimmed", () -> Main.scopeFor("  test-only  ").equals("test"));
        t.put("matching is case-sensitive", () -> rejects("Test-Only") && rejects("RUNTIME-ONLY"));
        t.put("unknown usages are rejected", () -> rejects("compile") && rejects("api"));
        t.put("null is rejected", () -> rejects(null));
        return t;
    }

    private static boolean rejects(String usage) {
        try {
            Main.scopeFor(usage);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
