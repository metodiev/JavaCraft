import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("healthy queue accepts", () -> Main.mayAccept(10, 100, 50, 1000));
        t.put("full queue rejects", () -> !Main.mayAccept(100, 100, 50, 1000));
        t.put("stale queue rejects", () -> !Main.mayAccept(10, 100, 1000, 1000));
        t.put("just below both limits accepts", () -> Main.mayAccept(99, 100, 999, 1000));
        t.put("empty queue with zero age accepts", () -> Main.mayAccept(0, 1, 0, 1));
        t.put("invalid values are rejected", () -> {
            try { Main.mayAccept(-1, 10, 0, 10); return false; } catch (IllegalArgumentException e) { }
            try { Main.mayAccept(0, 0, 0, 10); return false; } catch (IllegalArgumentException e) { }
            try { Main.mayAccept(0, 10, 0, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
