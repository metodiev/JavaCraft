import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("closed allows calls", () -> Main.mayCall(Main.State.CLOSED, 0, 1));
        t.put("open blocks calls", () -> !Main.mayCall(Main.State.OPEN, 0, 1));
        t.put("half-open allows a limited number of probes", () -> Main.mayCall(Main.State.HALF_OPEN, 0, 1)
                && !Main.mayCall(Main.State.HALF_OPEN, 1, 1));
        t.put("null state blocks calls", () -> !Main.mayCall(null, 0, 1));
        t.put("closed opens at the failure threshold", () ->
                Main.afterCall(Main.State.CLOSED, false, 3, 3) == Main.State.OPEN
                && Main.afterCall(Main.State.CLOSED, false, 2, 3) == Main.State.CLOSED);
        t.put("closed stays closed on success", () -> Main.afterCall(Main.State.CLOSED, true, 0, 3) == Main.State.CLOSED);
        t.put("half-open success closes", () -> Main.afterCall(Main.State.HALF_OPEN, true, 0, 3) == Main.State.CLOSED);
        t.put("half-open failure reopens", () -> Main.afterCall(Main.State.HALF_OPEN, false, 0, 3) == Main.State.OPEN);
        return t;
    }
}
