import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("invariant-critical operations are strong", () -> Main.forOperation(true, true) == Main.Level.STRONG
                && Main.forOperation(true, false) == Main.Level.STRONG);
        t.put("tolerating stale reads allows eventual", () -> Main.forOperation(false, true) == Main.Level.EVENTUAL);
        t.put("otherwise bounded staleness", () -> Main.forOperation(false, false) == Main.Level.BOUNDED_STALENESS);
        t.put("unknown criticality defaults to strong", () -> Main.forOperation(null, true) == Main.Level.STRONG
                && Main.forOperation(null, null) == Main.Level.STRONG);
        t.put("unknown staleness tolerance is not eventual", () -> Main.forOperation(false, null) == Main.Level.BOUNDED_STALENESS);
        return t;
    }
}
