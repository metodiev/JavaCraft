import java.util.*;
import java.util.concurrent.Callable;
import java.util.function.IntUnaryOperator;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a target reached on the first attempt counts once", () -> Main.casAttempts(0, 5, x -> x + 5) == 1);
        t.put("each retry adds one attempt", () -> Main.casAttempts(0, 3, x -> x + 1) == 3);
        t.put("a value already at the target takes no attempts", () -> Main.casAttempts(7, 7, x -> {
            throw new IllegalStateException("must not be called");
        }) == 0);
        t.put("an unreachable target stops at the bound", () -> Main.casAttempts(0, 9, x -> 0) == 1000);
        t.put("an overshooting update stops at the bound", () -> Main.casAttempts(0, 9, x -> x + 2) == 1000);
        t.put("the loop applies the operator to the previous result", () -> {
            int[] calls = {0};
            int[] args = new int[3];
            int attempts = Main.casAttempts(2, 20, x -> {
                args[calls[0]] = x;
                calls[0]++;
                return calls[0] == 1 ? 5 : x * 2;
            });
            return attempts == 3 && calls[0] == 3 && args[0] == 2 && args[1] == 5 && args[2] == 10;
        });
        t.put("a null operator is rejected", () -> {
            try {
                Main.casAttempts(0, 1, null);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
