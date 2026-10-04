import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("integrity risk always escalates", () -> Main.escalate(0, 0, true, 1000, 60));
        t.put("many affected users escalate", () -> Main.escalate(1000, 1, false, 1000, 60));
        t.put("long duration escalates", () -> Main.escalate(1, 60, false, 1000, 60));
        t.put("small short incident does not escalate", () -> !Main.escalate(10, 5, false, 1000, 60));
        t.put("invalid input is rejected even with integrity risk", () -> {
            try { Main.escalate(-1, 0, true, 10, 10); return false; } catch (IllegalArgumentException e) { }
            try { Main.escalate(0, -1, true, 10, 10); return false; } catch (IllegalArgumentException e) { }
            try { Main.escalate(0, 0, true, 0, 10); return false; } catch (IllegalArgumentException e) { }
            try { Main.escalate(0, 0, true, 10, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
