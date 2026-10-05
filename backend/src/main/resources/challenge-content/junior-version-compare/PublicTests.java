import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equal versions compare as zero", () -> Main.compare("1.2.3", "1.2.3") == 0);
        t.put("missing components count as zero", () ->
                Main.compare("1.2", "1.2.0") == 0 && Main.compare("1.2.0", "1.2") == 0);
        t.put("components compare numerically", () ->
                Main.compare("1.2", "1.10") < 0 && Main.compare("1.10", "1.2") > 0);
        t.put("the first larger component decides", () ->
                Main.compare("2.0", "1.9.9") > 0 && Main.compare("1.9.9", "2.0") < 0);
        t.put("a qualifier sorts before the bare version", () ->
                Main.compare("1.0-beta", "1.0") < 0 && Main.compare("1.0", "1.0-beta") > 0
                        && Main.compare("2.0-SNAPSHOT", "2.0") < 0);
        t.put("qualifiers compare lexically", () ->
                Main.compare("1.0-alpha", "1.0-beta") < 0 && Main.compare("1.0-rc1", "1.0-rc2") < 0);
        t.put("numeric differences outrank qualifiers", () ->
                Main.compare("2.0-alpha", "1.0") > 0 && Main.compare("1.0-beta", "2.0") < 0);
        t.put("null, blank, and non-numeric versions are rejected", () ->
                rejects(null) && rejects("  ") && rejects("1.x"));
        return t;
    }

    private static boolean rejects(String version) {
        try {
            Main.compare(version, "1.0");
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
