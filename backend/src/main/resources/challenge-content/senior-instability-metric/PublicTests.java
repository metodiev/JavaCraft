import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no coupling is zero instability", () -> near(Main.instability(0, 0), 0.0));
        t.put("only efferent coupling is fully unstable", () -> near(Main.instability(0, 5), 1.0));
        t.put("only afferent coupling is fully stable", () -> near(Main.instability(5, 0), 0.0));
        t.put("balanced coupling is half", () -> near(Main.instability(5, 5), 0.5));
        t.put("one efferent against three afferent is a quarter", () -> near(Main.instability(3, 1), 0.25));
        t.put("three efferent against one afferent is three quarters", () -> near(Main.instability(1, 3), 0.75));
        t.put("large symmetric counts do not overflow", () ->
                near(Main.instability(Integer.MAX_VALUE, Integer.MAX_VALUE), 0.5));
        t.put("negative coupling counts are rejected", () -> {
            try { Main.instability(-1, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.instability(0, -1); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }

    private static boolean near(double actual, double expected) {
        return Math.abs(actual - expected) < 0.0001;
    }
}
