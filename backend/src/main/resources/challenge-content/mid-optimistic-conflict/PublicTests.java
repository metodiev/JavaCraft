import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("attempts below the maximum are retried", () -> Main.action("OptimisticLockingFailureException", 0, 3, true).equals("RETRY")
                && Main.action("OptimisticLockingFailureException", 2, 3, true).equals("RETRY"));
        t.put("the attempt budget being used up is surfaced",
                () -> Main.action("OptimisticLockingFailureException", 3, 3, true).equals("SURFACE"));
        t.put("an unsafe replay is surfaced even with attempts left",
                () -> Main.action("OptimisticLockingFailureException", 0, 3, false).equals("SURFACE")
                        && Main.action("ObjectOptimisticLockingFailureException", 0, 5, false).equals("SURFACE"));
        t.put("a stale state exception never retries",
                () -> Main.action("StaleStateException", 0, 3, true).equals("SURFACE"));
        t.put("stale object state is a conflict that may retry",
                () -> Main.action("StaleObjectStateException", 0, 3, true).equals("RETRY"));
        t.put("a non-conflict exception never retries",
                () -> Main.action("DataIntegrityViolationException", 0, 3, true).equals("SURFACE")
                        && Main.action("NullPointerException", 0, 3, true).equals("SURFACE")
                        && Main.action(null, 0, 3, true).equals("SURFACE"));
        t.put("attempts equal to or above the maximum are surfaced",
                () -> Main.action("OptimisticLockingFailureException", 3, 3, true).equals("SURFACE")
                        && Main.action("OptimisticLockingFailureException", 4, 3, true).equals("SURFACE")
                        && Main.action("OptimisticLockingFailureException", -1, 0, true).equals("SURFACE"));
        return t;
    }
}
