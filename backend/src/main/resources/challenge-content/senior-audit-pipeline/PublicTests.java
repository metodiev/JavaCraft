import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("next sequence is accepted", () -> Main.isNext(5, 6));
        t.put("gap is rejected", () -> !Main.isNext(5, 8));
        t.put("duplicate is rejected", () -> !Main.isNext(5, 5));
        t.put("replay of an older event is rejected", () -> !Main.isNext(5, 2));
        t.put("overflow wrap-around is rejected", () -> !Main.isNext(Long.MAX_VALUE, Long.MIN_VALUE));
        t.put("zero start is valid", () -> Main.isNext(0, 1));
        t.put("negative previous is rejected", () -> {
            try { Main.isNext(-1, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
