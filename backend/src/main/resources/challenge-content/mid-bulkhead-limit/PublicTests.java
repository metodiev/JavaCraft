import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("capacity is divided evenly with a reserve", () -> Main.limit(100, 4, 20) == 20);
        t.put("the reserve is subtracted before dividing", () -> Main.limit(100, 4, 25) == 18);
        t.put("shares round down", () -> Main.limit(10, 3, 0) == 3);
        t.put("no reserve keeps all capacity in play", () -> Main.limit(30, 5, 0) == 6);
        t.put("every dependency gets at least one permit", () ->
                Main.limit(1, 5, 0) == 1 && Main.limit(2, 2, 50) == 1);
        t.put("invalid inputs are rejected", () -> {
            try { Main.limit(0, 1, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.limit(10, 0, 0); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.limit(10, 1, 100); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.limit(10, 1, -1); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
