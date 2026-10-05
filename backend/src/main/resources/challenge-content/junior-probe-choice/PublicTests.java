import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a startup purpose chooses STARTUP", () -> "STARTUP".equals(Main.probeFor("startup check"))
                && "STARTUP".equals(Main.probeFor("boot verification")));
        t.put("a readiness purpose chooses READINESS", () -> "READINESS".equals(Main.probeFor("readiness check"))
                && "READINESS".equals(Main.probeFor("may receive traffic")));
        t.put("a liveness purpose chooses LIVENESS", () -> "LIVENESS".equals(Main.probeFor("liveness check"))
                && "LIVENESS".equals(Main.probeFor("detect a deadlock")));
        t.put("matching is case insensitive", () -> "READINESS".equals(Main.probeFor("READY"))
                && "LIVENESS".equals(Main.probeFor("Restart")));
        t.put("an unknown purpose gives NONE", () -> "NONE".equals(Main.probeFor("performance")));
        t.put("a null purpose gives NONE", () -> "NONE".equals(Main.probeFor(null)));
        t.put("a blank purpose gives NONE", () -> "NONE".equals(Main.probeFor(""))
                && "NONE".equals(Main.probeFor("   ")));
        t.put("STARTUP is checked before READINESS", () -> "STARTUP".equals(Main.probeFor("startup readiness")));
        return t;
    }
}
