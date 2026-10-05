import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an already warm method needs no invocations", () -> Main.warmupInvocations(100, 100, 10) == 0
                && Main.warmupInvocations(100, 250, 10) == 0);
        t.put("fewer invocations are needed as the target nears", () -> Main.warmupInvocations(1000, 200, 100) == 8);
        t.put("the estimate is rounded up to whole steps", () -> Main.warmupInvocations(1000, 950, 100) == 1
                && Main.warmupInvocations(1000, 949, 100) == 1);
        t.put("a step of zero is treated as one", () -> Main.warmupInvocations(1000, 200, 0) == 800
                && Main.warmupInvocations(1000, 200, -5) == 800);
        t.put("never more than a million invocations", () -> Main.warmupInvocations(Integer.MAX_VALUE, 1, 1) == 1_000_000);
        t.put("the result is always positive when cold and zero when warm", () -> Main.warmupInvocations(5, 0, 7) == 1
                && Main.warmupInvocations(0, 0, 7) == 0);
        t.put("a huge step still reports one step", () -> Main.warmupInvocations(1000, 1, 5000) == 1);
        return t;
    }
}
