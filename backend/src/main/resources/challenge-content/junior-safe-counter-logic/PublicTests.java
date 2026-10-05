import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("returns the next value below the limit", () -> Main.nextValue(5, 10) == 6);
        t.put("wraps to zero when the limit is reached", () -> Main.nextValue(10, 10) == 0);
        t.put("next value can land exactly on the limit", () -> Main.nextValue(9, 10) == 10);
        t.put("a value above the limit wraps to zero", () -> Main.nextValue(12, 10) == 0);
        t.put("maximum limit does not overflow", () -> Main.nextValue(Integer.MAX_VALUE, Integer.MAX_VALUE) == 0);
        t.put("zero limit wraps immediately", () -> Main.nextValue(0, 0) == 0);
        t.put("negative current is rejected", () -> {
            try {
                Main.nextValue(-1, 10);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("negative limit is rejected", () -> {
            try {
                Main.nextValue(0, -5);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
