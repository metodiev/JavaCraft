import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a burn rate above the factor fires", () -> Main.alert(0.5, 0.25, 1.5));
        t.put("a burn rate below the factor stays silent", () -> !Main.alert(0.5, 0.25, 3.0));
        t.put("exactly at the factor does not fire", () -> !Main.alert(0.5, 0.25, 2.0));
        t.put("the classic one hour fast burn fires", () -> Main.alert(0.05, 1.0 / 720.0, 14.4));
        t.put("a slow burn stays below the fast factor", () -> !Main.alert(0.02, 1.0 / 30.0, 14.4));
        t.put("an overspent budget fires", () -> Main.alert(1.5, 0.5, 2.5));
        t.put("a full window uses the consumed fraction directly",
                () -> Main.alert(0.2, 1.0, 0.19) && !Main.alert(0.2, 1.0, 0.2));
        t.put("invalid inputs are rejected",
                () -> rejects(0.5, 0, 1) && rejects(-0.1, 0.5, 1) && rejects(0.5, 1.5, 1)
                        && rejects(0.5, 0.5, 0) && rejects(0.5, 0.5, Double.NaN));
        return t;
    }

    private static boolean rejects(double consumed, double window, double factor) {
        try {
            Main.alert(consumed, window, factor);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
