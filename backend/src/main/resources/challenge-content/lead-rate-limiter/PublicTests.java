import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    private static final Instant T0 = Instant.parse("2026-01-01T00:00:00Z");
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("requests up to the limit are allowed", () -> {
            Main m = new Main(2, Duration.ofSeconds(10), 10);
            return m.allow("a", T0) && m.allow("a", T0.plusSeconds(1)) && !m.allow("a", T0.plusSeconds(2));
        });
        t.put("tenants are limited independently", () -> {
            Main m = new Main(1, Duration.ofSeconds(10), 10);
            return m.allow("a", T0) && m.allow("b", T0) && !m.allow("a", T0);
        });
        t.put("a new window resets the count", () -> {
            Main m = new Main(1, Duration.ofSeconds(10), 10);
            return m.allow("a", T0) && !m.allow("a", T0.plusSeconds(9)) && m.allow("a", T0.plusSeconds(10));
        });
        t.put("windows are aligned to the epoch", () -> {
            Main m = new Main(1, Duration.ofSeconds(10), 10);
            return m.allow("a", T0.plusSeconds(9)) && m.allow("a", T0.plusSeconds(10));
        });
        t.put("new tenants are refused when tracking is full", () -> {
            Main m = new Main(5, Duration.ofSeconds(10), 2);
            return m.allow("a", T0) && m.allow("b", T0) && !m.allow("c", T0) && m.allow("a", T0);
        });
        t.put("stale tenants are evicted to make room", () -> {
            Main m = new Main(5, Duration.ofSeconds(10), 1);
            return m.allow("a", T0) && m.allow("b", T0.plusSeconds(10));
        });
        t.put("invalid configuration is rejected", () -> {
            try { new Main(0, Duration.ofSeconds(1), 1); return false; } catch (IllegalArgumentException e) { }
            try { new Main(1, Duration.ZERO, 1); return false; } catch (IllegalArgumentException e) { }
            try { new Main(1, Duration.ofSeconds(1), 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("missing tenant or time is rejected", () -> {
            Main m = new Main(1, Duration.ofSeconds(1), 1);
            try { m.allow(null, T0); return false; } catch (IllegalArgumentException e) { }
            try { m.allow("a", null); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
