import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the first attempt waits the initial delay", () -> Main.delayMillis(1, 100L, 2.0, 10000L) == 100L);
        t.put("the second attempt doubles the delay", () -> Main.delayMillis(2, 100L, 2.0, 10000L) == 200L);
        t.put("the third attempt doubles again", () -> Main.delayMillis(3, 100L, 2.0, 10000L) == 400L);
        t.put("an attempt below one is treated as the first attempt", () ->
                Main.delayMillis(0, 100L, 2.0, 10000L) == 100L && Main.delayMillis(-5, 100L, 2.0, 10000L) == 100L);
        t.put("the delay never exceeds max", () -> Main.delayMillis(20, 100L, 2.0, 5000L) == 5000L
                && Main.delayMillis(5, 100L, 2.0, 500L) == 500L);
        t.put("no attempt overflows long", () -> Main.delayMillis(Integer.MAX_VALUE, 100L, 2.0, Long.MAX_VALUE) <= Long.MAX_VALUE);
        t.put("a multiplier of one keeps the delay constant", () -> Main.delayMillis(9, 250L, 1.0, 100000L) == 250L);
        t.put("a fractional multiplier rounds down to whole milliseconds", () ->
                Main.delayMillis(2, 101L, 1.5, 100000L) == 151L);
        t.put("a max below the computed delay still caps the result", () ->
                Main.delayMillis(1, 1000L, 2.0, 10L) == 10L);
        return t;
    }
}
