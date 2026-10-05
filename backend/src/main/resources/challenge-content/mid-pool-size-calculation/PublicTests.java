import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("wait free work needs one thread per core", () -> Main.poolSize(1.0, 0, 100, 8) == 8);
        t.put("blocking work grows the pool", () -> Main.poolSize(1.0, 500, 500, 8) == 16);
        t.put("utilisation scales the pool", () -> Main.poolSize(0.5, 0, 10, 8) == 4);
        t.put("partial threads round up", () -> Main.poolSize(1.0, 1, 2, 3) == 5);
        t.put("small pools never drop below one thread", () -> Main.poolSize(0.01, 0, 100, 1) == 1);
        t.put("the pool is capped at 200 threads", () -> Main.poolSize(1.0, 1_000_000, 1, 64) == 200);
        t.put("service time at or below zero is rejected", () -> {
            try {
                Main.poolSize(1.0, 10, 0, 4);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("utilisation outside (0, 1] is rejected", () -> {
            try {
                Main.poolSize(0, 10, 10, 4);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("negative wait time is rejected", () -> {
            try {
                Main.poolSize(1.0, -1, 10, 4);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
