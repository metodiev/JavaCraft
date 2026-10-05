import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a matching scope is authorised",
                () -> Main.authorised(Set.of("read", "write"), "write", false));
        t.put("a missing scope is denied",
                () -> !Main.authorised(Set.of("read"), "write", false));
        t.put("scope matching is case-sensitive",
                () -> !Main.authorised(Set.of("Read"), "read", false)
                        && !Main.authorised(Set.of("READ"), "read", false));
        t.put("the admin scope grants every scope",
                () -> Main.authorised(Set.of("admin"), "write", false)
                        && Main.authorised(Set.of("admin", "read"), "payments:write", false));
        t.put("an admin bypass grants even without any scope",
                () -> Main.authorised(Set.of(), "write", true)
                        && Main.authorised(null, "write", true));
        t.put("a null scope set is denied without a bypass",
                () -> !Main.authorised(null, "read", false));
        t.put("a null, blank or non-matching scope value is denied",
                () -> !Main.authorised(Set.of("read"), null, false)
                        && !Main.authorised(Set.of("read"), "", false)
                        && !Main.authorised(Set.of("read write"), "read", false));
        return t;
    }
}
