import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("cost per success divides cost by successes", () -> Main.costPerSuccess(100, 50) == 2.0);
        t.put("no successes is infinitely expensive", () -> Main.costPerSuccess(100, 0) == Double.POSITIVE_INFINITY);
        t.put("cheaper per success wins, not cheaper overall", () -> Main.cheaperOption(100, 10, 150, 30).equals("B"));
        t.put("option A can win", () -> Main.cheaperOption(10, 10, 50, 10).equals("A"));
        t.put("equal unit cost ties", () -> Main.cheaperOption(10, 5, 20, 10).equals("TIE"));
        t.put("an option with no successes loses", () -> Main.cheaperOption(1, 0, 1000, 1).equals("B"));
        t.put("two options with no successes tie", () -> Main.cheaperOption(1, 0, 2, 0).equals("TIE"));
        t.put("invalid inputs are rejected", () -> {
            try { Main.costPerSuccess(-1, 1); return false; } catch (IllegalArgumentException e) { }
            try { Main.costPerSuccess(1, -1); return false; } catch (IllegalArgumentException e) { }
            try { Main.costPerSuccess(Double.NaN, 1); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
