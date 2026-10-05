import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("splits evenly across attempts", () -> {
            Map<String, Long> b = Main.budget(3000, 3);
            return b.get("budget") == 3000L && b.get("connect") == 500L && b.get("read") == 500L;
        });
        t.put("connect and read sum to the per attempt share", () -> {
            Map<String, Long> b = Main.budget(100, 4);
            return b.get("connect") == 13L && b.get("read") == 12L
                    && b.get("connect") + b.get("read") == 25L;
        });
        t.put("a single attempt uses the whole budget", () -> {
            Map<String, Long> b = Main.budget(500, 1);
            return b.get("budget") == 500L && b.get("connect") == 250L && b.get("read") == 250L;
        });
        t.put("remainders stay inside the total", () -> {
            Map<String, Long> b = Main.budget(1000, 3);
            return b.get("budget") == 1000L && b.get("connect") + b.get("read") == 333L
                    && b.get("connect") >= b.get("read");
        });
        t.put("keys are exactly budget connect read", () -> Main.budget(60, 2).keySet()
                .equals(new HashSet<>(Set.of("budget", "connect", "read"))));
        t.put("the smallest budget can leave a zero share", () -> {
            Map<String, Long> b = Main.budget(1, 5);
            return b.get("budget") == 1L && b.get("connect") == 0L && b.get("read") == 0L;
        });
        t.put("a non-positive total is rejected", () -> {
            try {
                Main.budget(0, 3);
                return false;
            } catch (IllegalArgumentException e) {
                // fall through
            }
            try {
                Main.budget(-10, 3);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("a non-positive attempts count is rejected", () -> {
            try {
                Main.budget(100, 0);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
