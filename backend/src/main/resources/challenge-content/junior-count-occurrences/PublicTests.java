import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts repeated matches", () -> Main.occurrences(List.of("a", "b", "a", "a"), "a") == 3);
        t.put("returns zero when nothing matches", () -> Main.occurrences(List.of("a", "b"), "c") == 0);
        t.put("skips null entries instead of failing", () -> Main.occurrences(Arrays.asList("a", null, "a"), "a") == 2);
        t.put("null target counts nothing", () -> Main.occurrences(Arrays.asList("a", null, "a"), null) == 0);
        t.put("null list yields zero", () -> Main.occurrences(null, "a") == 0);
        t.put("empty list yields zero", () -> Main.occurrences(Collections.emptyList(), "a") == 0);
        t.put("counts duplicate targets case-sensitively", () -> Main.occurrences(List.of("A", "a", "a"), "a") == 2);
        return t;
    }
}
