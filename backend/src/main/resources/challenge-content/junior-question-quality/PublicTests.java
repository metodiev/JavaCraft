import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null question misses everything", () -> Main.missingParts(null).equals(List.of(
                "missing context", "missing attempted steps", "missing minimal reproduction")));
        t.put("a complete question has no gaps", () -> Main.missingParts(
                "Context: running the parser on Java 21. I tried updating the grammar. Minimal example: three lines that reproduce it.")
                .isEmpty());
        t.put("question without context", () -> Main.missingParts(
                "I tried restarting the service. Minimal example: gradle test fails.").equals(List.of("missing context")));
        t.put("question without a reproduction", () -> Main.missingParts(
                "Context: CI fails on main. I tried clearing the cache.").equals(List.of("missing minimal reproduction")));
        t.put("question without attempted steps", () -> Main.missingParts(
                "Context: CI is broken. Minimal example: the failing job log.").equals(List.of("missing attempted steps")));
        t.put("matching is case insensitive and trimmed", () -> Main.missingParts(
                " CONTEXT: x. I TRIED y. MINIMAL EXAMPLE: z. ").isEmpty());
        t.put("blank parts are treated as missing", () -> Main.missingParts(
                "Context:    I tried restarting. Minimal example: repro.").equals(List.of("missing context")));
        return t;
    }
}
