import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("success exits with zero", () -> Main.exitCode(true, true) == 0 && Main.exitCode(true, false) == 0);
        t.put("retryable failure exits with seventy five", () -> Main.exitCode(false, true) == 75);
        t.put("permanent failure exits with one", () -> Main.exitCode(false, false) == 1);
        t.put("only success returns zero", () -> Main.exitCode(false, true) != 0 && Main.exitCode(false, false) != 0);
        t.put("the two failure codes differ", () -> Main.exitCode(false, true) != Main.exitCode(false, false));
        return t;
    }
}
