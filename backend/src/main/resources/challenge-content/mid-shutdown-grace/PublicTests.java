import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("grace covers the longest request plus the drain", () -> Main.graceSeconds(10, 5, 60) == 15);
        t.put("a smaller terminationGrace value caps the grace", () -> Main.graceSeconds(10, 5, 12) == 12);
        t.put("exactly enough terminationGrace is used in full", () -> Main.graceSeconds(10, 5, 15) == 15);
        t.put("terminal grace of zero is rejected", () -> {
            try { Main.graceSeconds(10, 5, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("a negative request duration is rejected", () -> {
            try { Main.graceSeconds(-1, 5, 60); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("a negative drain is rejected", () -> {
            try { Main.graceSeconds(10, -1, 60); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("zero request and drain return zero", () -> Main.graceSeconds(0, 0, 30) == 0);
        t.put("overflowing sums are rejected", () -> {
            try { Main.graceSeconds(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
