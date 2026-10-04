import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("first page starts at zero", () -> Main.offset(new Main.PageRequest(0, 20)) == 0);
        t.put("offset is page times size", () -> Main.offset(new Main.PageRequest(3, 25)) == 75);
        t.put("large pages do not overflow int", () -> Main.offset(new Main.PageRequest(Integer.MAX_VALUE, 100))
                == 214748364700L);
        t.put("size above 100 is rejected", () -> rejects(new Main.PageRequest(0, 101)));
        t.put("size below 1 is rejected", () -> rejects(new Main.PageRequest(0, 0)));
        t.put("negative page is rejected", () -> rejects(new Main.PageRequest(-1, 10)));
        t.put("null request is rejected", () -> rejects(null));
        return t;
    }

    private static boolean rejects(Main.PageRequest request) {
        try { Main.offset(request); return false; } catch (IllegalArgumentException e) { return true; }
    }
}
