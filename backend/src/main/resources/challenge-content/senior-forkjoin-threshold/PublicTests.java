import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("cheap work uses the minimum chunk", () -> Main.threshold(500_000, 8, 1) == 1000);
        t.put("moderate cost sizes the chunk from the total work", () -> Main.threshold(24_000, 8, 1_000) == 30_000);
        t.put("exactly the minimum chunk is kept", () -> Main.threshold(8_000, 8, 100) == 1000);
        t.put("exactly the maximum chunk is kept", () -> Main.threshold(80_000, 8, 1_000) == 100_000);
        t.put("huge totals are capped without overflow", () -> Main.threshold(Integer.MAX_VALUE, 1, Integer.MAX_VALUE) == 100_000);
        t.put("empty input uses the minimum chunk", () -> Main.threshold(0, 4, 50) == 1000);
        t.put("negative element counts use the minimum chunk", () -> Main.threshold(-5, 4, 50) == 1000);
        t.put("non-positive cores or cost use the minimum chunk", () -> Main.threshold(1000, 0, 500) == 1000 && Main.threshold(1000, 8, 0) == 1000);
        return t;
    }
}
