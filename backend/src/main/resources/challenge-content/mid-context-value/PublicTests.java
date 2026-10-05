import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a key written by the subscription is visible", () -> Main.visible("tenant", Set.of("tenant", "trace")));
        t.put("a key missing from the subscription is not visible", () -> !Main.visible("tenant", Set.of("trace")));
        t.put("an empty context hides every key", () -> !Main.visible("tenant", Set.of()));
        t.put("a null key is never visible", () -> !Main.visible(null, Set.of("tenant")));
        t.put("a null context hides every key", () -> !Main.visible("tenant", null));
        t.put("matching is case-sensitive", () -> !Main.visible("Tenant", Set.of("tenant")));
        t.put("a key from another subscription stays invisible", () -> !Main.visible("tenant", Set.of("trace", "span")));
        return t;
    }
}
