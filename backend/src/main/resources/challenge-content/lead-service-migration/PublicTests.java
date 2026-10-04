import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("cut over needs all three conditions", () -> Main.mayCutOver(true, true, true)
                && !Main.mayCutOver(false, true, true) && !Main.mayCutOver(true, false, true)
                && !Main.mayCutOver(true, true, false));
        t.put("traffic starts at 1 percent", () -> Main.nextTrafficPercent(0, true) == 1);
        t.put("traffic follows the staged steps", () -> Main.nextTrafficPercent(1, true) == 5
                && Main.nextTrafficPercent(5, true) == 25 && Main.nextTrafficPercent(25, true) == 50
                && Main.nextTrafficPercent(50, true) == 100);
        t.put("full traffic stays at 100", () -> Main.nextTrafficPercent(100, true) == 100);
        t.put("unhealthy rolls back to zero", () -> Main.nextTrafficPercent(25, false) == 0);
        t.put("off-step values move to the next step", () -> Main.nextTrafficPercent(10, true) == 25);
        t.put("out-of-range values are rejected", () -> {
            try { Main.nextTrafficPercent(-1, true); return false; } catch (IllegalArgumentException e) { }
            try { Main.nextTrafficPercent(101, true); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
