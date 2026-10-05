import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a called method is verified once with its argument", () ->
                Main.verifyPlan(true, 1, false).equals(List.of("verify once with expected argument")));
        t.put("repeated calls are verified with a count", () ->
                Main.verifyPlan(true, 3, false).equals(List.of("verify times(3)")));
        t.put("an unused method is never verified", () ->
                Main.verifyPlan(false, 0, false).isEmpty());
        t.put("idempotency adds a second verification", () ->
                Main.verifyPlan(true, 2, true).equals(List.of("verify times(2)", "verify payload is unchanged")));
        t.put("an unused method still needs the idempotency check", () ->
                Main.verifyPlan(false, 0, true).equals(List.of("verify payload is unchanged")));
        t.put("a zero count is treated as never called", () ->
                Main.verifyPlan(true, 0, false).isEmpty() && Main.verifyPlan(true, 0, true).equals(List.of("verify payload is unchanged")));
        t.put("a negative count is treated as never called", () ->
                Main.verifyPlan(true, -2, false).isEmpty() && Main.verifyPlan(false, -2, true).equals(List.of("verify payload is unchanged")));
        return t;
    }
}
