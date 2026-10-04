import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Instant start = Instant.parse("2026-01-01T00:00:00Z");
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("entry within ttl is fresh", () -> Main.isFresh(start, start.plusSeconds(30), 60));
        t.put("entry exactly at ttl is expired", () -> !Main.isFresh(start, start.plusSeconds(60), 60));
        t.put("entry past ttl is expired", () -> !Main.isFresh(start, start.plusSeconds(61), 60));
        t.put("zero ttl is always expired", () -> !Main.isFresh(start, start, 0));
        t.put("huge ttl does not overflow", () -> Main.isFresh(start, start.plusSeconds(10), Long.MAX_VALUE));
        t.put("clock moving backwards is rejected", () -> rejects(start, start.minusSeconds(1), 60));
        t.put("negative ttl is rejected", () -> rejects(start, start, -1));
        t.put("null time is rejected", () -> rejects(null, start, 60) && rejects(start, null, 60));
        return t;
    }

    private static boolean rejects(Instant created, Instant now, long ttl) {
        try { Main.isFresh(created, now, ttl); return false; } catch (IllegalArgumentException e) { return true; }
    }
}
