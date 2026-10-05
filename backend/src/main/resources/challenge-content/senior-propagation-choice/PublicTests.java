import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a normal write joins the caller transaction", () ->
                "REQUIRED".equals(Main.propagationFor("write")));
        t.put("an audit write survives a caller rollback through a new transaction", () ->
                "REQUIRES_NEW".equals(Main.propagationFor("audit")));
        t.put("a long read outside a transaction is not supported", () ->
                "NOT_SUPPORTED".equals(Main.propagationFor("long-read")));
        t.put("the scenario is matched ignoring case and surrounding whitespace", () ->
                "REQUIRES_NEW".equals(Main.propagationFor("  AUDIT ")) && "REQUIRED".equals(Main.propagationFor("Write")));
        t.put("an unknown scenario defaults to REQUIRED", () ->
                "REQUIRED".equals(Main.propagationFor("batch-import")));
        t.put("a null scenario defaults to REQUIRED", () -> "REQUIRED".equals(Main.propagationFor(null)));
        t.put("every documented scenario maps to a documented value", () -> {
            List<String> expected = List.of("REQUIRED", "REQUIRES_NEW", "NOT_SUPPORTED");
            return List.of("write", "audit", "long-read").stream()
                    .map(Main::propagationFor)
                    .allMatch(expected::contains);
        });
        t.put("a rejected scenario never returns null", () -> Main.propagationFor("") != null);
        return t;
    }
}
