import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("fenced primary and small lag may promote", () -> Main.mayPromote(100, 500, true));
        t.put("lag equal to the limit may promote", () -> Main.mayPromote(500, 500, true));
        t.put("lag above the limit may not promote", () -> !Main.mayPromote(501, 500, true));
        t.put("unfenced old primary may not promote", () -> !Main.mayPromote(0, 500, false));
        t.put("negative lag is untrusted", () -> !Main.mayPromote(-1, 500, true));
        t.put("negative limit is untrusted", () -> !Main.mayPromote(0, -1, true));
        return t;
    }
}
