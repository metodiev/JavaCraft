import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("expected failure is a warning", () -> Main.levelFor("expected-failure").equals("WARN"));
        t.put("unexpected failure is an error", () -> Main.levelFor("unexpected-failure").equals("ERROR"));
        t.put("routine detail is debug", () -> Main.levelFor("routine-detail").equals("DEBUG"));
        t.put("normal lifecycle is info", () -> Main.levelFor("lifecycle").equals("INFO"));
        t.put("category is matched case-insensitively and trimmed",
                () -> Main.levelFor("  Unexpected-Failure ").equals("ERROR"));
        t.put("unknown category is rejected", () -> rejects("warning"));
        t.put("blank category is rejected", () -> rejects("   "));
        t.put("null category is rejected", () -> rejects(null));
        return t;
    }

    private static boolean rejects(String event) {
        try {
            Main.levelFor(event);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
