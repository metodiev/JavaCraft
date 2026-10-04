import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("all successes are reported in order", () -> {
            Main.BatchResult r = Main.process(List.of("a", "b"), x -> {});
            return r.succeeded().equals(List.of("a", "b")) && r.failed().isEmpty();
        });
        t.put("a failure does not stop later items", () -> {
            List<String> seen = new ArrayList<>();
            Main.BatchResult r = Main.process(List.of("a", "bad", "c"), x -> {
                if (x.equals("bad")) throw new IllegalStateException("boom");
                seen.add(x);
            });
            return seen.equals(List.of("a", "c")) && r.succeeded().equals(List.of("a", "c"))
                    && r.failed().equals(List.of("bad"));
        });
        t.put("empty batch is empty result", () -> {
            Main.BatchResult r = Main.process(List.of(), x -> {});
            return r.succeeded().isEmpty() && r.failed().isEmpty();
        });
        t.put("null list is rejected", () -> {
            try { Main.process(null, x -> {}); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("null element is rejected", () -> {
            try { Main.process(Arrays.asList("a", null), x -> {}); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
