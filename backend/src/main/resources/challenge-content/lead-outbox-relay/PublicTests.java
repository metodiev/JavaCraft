import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("messages are claimed oldest first, once", () -> {
            Main m = new Main(3);
            m.add("a"); m.add("b");
            return m.claim().equals(Optional.of("a")) && m.claim().equals(Optional.of("b")) && m.claim().isEmpty();
        });
        t.put("claim marks a message in flight", () -> {
            Main m = new Main(3);
            m.add("a"); m.claim();
            return m.status("a") == Main.Status.IN_FLIGHT;
        });
        t.put("confirm delivers", () -> {
            Main m = new Main(3);
            m.add("a"); m.claim(); m.confirm("a");
            return m.status("a") == Main.Status.DELIVERED && m.claim().isEmpty();
        });
        t.put("transient failure returns to pending for retry", () -> {
            Main m = new Main(3);
            m.add("a"); m.claim(); m.fail("a", true);
            return m.status("a") == Main.Status.PENDING && m.claim().equals(Optional.of("a"));
        });
        t.put("permanent failure is final", () -> {
            Main m = new Main(3);
            m.add("a"); m.claim(); m.fail("a", false);
            return m.status("a") == Main.Status.FAILED && m.claim().isEmpty();
        });
        t.put("attempts are capped", () -> {
            Main m = new Main(2);
            m.add("a");
            m.claim(); m.fail("a", true);
            m.claim(); m.fail("a", true);
            return m.status("a") == Main.Status.FAILED;
        });
        t.put("duplicate add does not reset a message", () -> {
            Main m = new Main(3);
            m.add("a"); m.claim(); m.confirm("a"); m.add("a");
            return m.status("a") == Main.Status.DELIVERED;
        });
        t.put("unknown id has no status and confirm is rejected", () -> {
            Main m = new Main(3);
            if (m.status("zzz") != null) return false;
            try { m.confirm("zzz"); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
