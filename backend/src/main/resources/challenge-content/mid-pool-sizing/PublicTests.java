import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a wait budget equal to the service time doubles the pool",
                () -> Main.poolSize(4, 10, 10) == 8);
        t.put("no wait budget keeps one connection per core",
                () -> Main.poolSize(3, 20, 0) == 3);
        t.put("the pool never drops below two",
                () -> Main.poolSize(1, 100, 0) == 2 && Main.poolSize(2, 5, 0) == 2);
        t.put("a fractional ratio rounds up", () -> Main.poolSize(2, 10, 11) == 5);
        t.put("the pool is capped at eight times the cores",
                () -> Main.poolSize(2, 1, 1_000_000) == 16);
        t.put("a ratio that lands exactly on the cap is kept",
                () -> Main.poolSize(1, 1, 7) == 8);
        t.put("invalid sizing inputs are rejected",
                () -> rejects(0, 10, 10) && rejects(4, 0, 10) && rejects(4, -1, 10)
                        && rejects(4, Double.NaN, 10) && rejects(4, 10, -1)
                        && rejects(4, 10, Double.POSITIVE_INFINITY));
        return t;
    }

    private static boolean rejects(int cores, double serviceTime, double waitBudget) {
        try {
            Main.poolSize(cores, serviceTime, waitBudget);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
