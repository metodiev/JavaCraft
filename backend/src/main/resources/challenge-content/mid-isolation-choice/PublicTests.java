import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("dirty reads need read committed", () -> Main.isolationFor("dirty-read").equals("READ COMMITTED"));
        t.put("fuzzy reads need repeatable read", () -> Main.isolationFor("non-repeatable-read").equals("REPEATABLE READ"));
        t.put("phantoms need serializable", () -> Main.isolationFor("phantom-read").equals("SERIALIZABLE"));
        t.put("lost updates need repeatable read", () -> Main.isolationFor("lost-update").equals("REPEATABLE READ"));
        t.put("write skew needs serializable", () -> Main.isolationFor("write-skew").equals("SERIALIZABLE"));
        t.put("an already defended scenario can stay read committed", () -> Main.isolationFor("read-only-report")
                .equals("READ COMMITTED"));
        t.put("unknown scenarios are rejected", () -> rejects("something-else"));
        t.put("null scenario is rejected", () -> rejects(null));
        return t;
    }

    private static boolean rejects(String scenario) {
        try { Main.isolationFor(scenario); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
