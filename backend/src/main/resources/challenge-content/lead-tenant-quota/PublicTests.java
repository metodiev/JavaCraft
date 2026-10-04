import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("within both limits is admitted", () -> Main.mayAdmit(2, 5, 10, 100, 2));
        t.put("exactly reaching the limits is admitted", () -> Main.mayAdmit(3, 5, 98, 100, 2));
        t.put("tenant limit is enforced", () -> !Main.mayAdmit(4, 5, 10, 100, 2));
        t.put("global limit is enforced", () -> !Main.mayAdmit(0, 5, 99, 100, 2));
        t.put("sums do not overflow", () -> !Main.mayAdmit(Integer.MAX_VALUE, Integer.MAX_VALUE, 0, 10, 1)
                && !Main.mayAdmit(0, 10, Integer.MAX_VALUE, Integer.MAX_VALUE, 1));
        t.put("invalid values are rejected", () -> {
            try { Main.mayAdmit(-1, 5, 0, 5, 1); return false; } catch (IllegalArgumentException e) { }
            try { Main.mayAdmit(0, 5, 0, 5, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
