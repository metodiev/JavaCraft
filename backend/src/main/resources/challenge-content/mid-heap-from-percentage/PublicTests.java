import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("quarter of a gibibyte is exact", () -> Main.maxHeapBytes(1_073_741_824L, 25) == 268_435_456L);
        t.put("percentage is clamped to one at the bottom", () -> Main.maxHeapBytes(100L, 0) == 1L
                && Main.maxHeapBytes(100L, -50) == 1L);
        t.put("percentage is clamped to one hundred at the top", () -> Main.maxHeapBytes(999L, 100) == 999L
                && Main.maxHeapBytes(999L, 101) == 999L);
        t.put("integer division truncates", () -> Main.maxHeapBytes(999L, 33) == 329L
                && Main.maxHeapBytes(1L, 1) == 0L);
        t.put("non positive container sizes round down to zero", () -> Main.maxHeapBytes(0L, 50) == 0L
                && Main.maxHeapBytes(-100L, 50) == 0L);
        t.put("no overflow for huge containers", () -> Main.maxHeapBytes(Long.MAX_VALUE, 100) == Long.MAX_VALUE
                && Main.maxHeapBytes(Long.MAX_VALUE, 50) == Long.MAX_VALUE / 2);
        return t;
    }
}
