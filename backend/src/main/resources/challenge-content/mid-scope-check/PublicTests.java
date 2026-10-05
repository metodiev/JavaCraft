import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("nothing required is always permitted", () -> Main.permits(Set.of(), List.of(), true) && Main.permits(null, null, false));
        t.put("requireAll needs every scope", () -> Main.permits(Set.of("read", "write"), List.of("read", "write"), true)
                && !Main.permits(Set.of("read"), List.of("read", "write"), true));
        t.put("any mode needs one scope", () -> Main.permits(Set.of("read"), List.of("write", "read"), false));
        t.put("any mode fails when none match", () -> !Main.permits(Set.of("read"), List.of("write", "delete"), false));
        t.put("missing grants fail", () -> !Main.permits(null, List.of("read"), false) && !Main.permits(Set.of(), List.of("read"), true));
        t.put("scope matching is exact and case sensitive", () -> !Main.permits(Set.of("Read"), List.of("read"), false)
                && !Main.permits(Set.of("read.*"), List.of("read"), true));
        t.put("repeated required scopes do not change the answer", () -> Main.permits(Set.of("read"), List.of("read", "read"), true));
        t.put("extra granted scopes are harmless", () -> Main.permits(Set.of("read", "write", "admin"), List.of("read"), true));
        return t;
    }
}
