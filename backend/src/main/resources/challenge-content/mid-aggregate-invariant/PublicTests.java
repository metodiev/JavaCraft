import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a request within capacity is allowed", () -> Main.canAddItem(0, 10, 5));
        t.put("filling the aggregate exactly is allowed", () -> Main.canAddItem(7, 10, 3));
        t.put("a request beyond capacity is rejected", () -> !Main.canAddItem(8, 10, 3));
        t.put("a full aggregate rejects any positive request", () -> !Main.canAddItem(10, 10, 1));
        t.put("zero requests are rejected", () -> !Main.canAddItem(0, 10, 0) && !Main.canAddItem(3, 3, 0));
        t.put("negative requests are rejected", () -> !Main.canAddItem(0, 10, -2) && !Main.canAddItem(5, 10, -1));
        t.put("a corrupt current count is rejected", () -> !Main.canAddItem(-1, 10, 1) && !Main.canAddItem(11, 10, 1));
        t.put("a negative capacity blocks every request", () -> !Main.canAddItem(0, -5, 1) && !Main.canAddItem(-1, -5, 10));
        return t;
    }
}
