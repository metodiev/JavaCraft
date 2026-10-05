import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("long cpu-bound work uses platform threads", () -> Main.chooseThreadType(false, true, false, 100).equals("platform"));
        t.put("heavy thread-local use uses platform threads", () -> Main.chooseThreadType(true, false, true, 100).equals("platform"));
        t.put("cpu-bound work keeps platform threads even with heavy thread-locals", () -> Main.chooseThreadType(false, true, true, 100).equals("platform"));
        t.put("high-throughput io-bound work uses virtual threads", () -> Main.chooseThreadType(true, false, false, 50_000).equals("virtual"));
        t.put("low-throughput blocking work stays platform", () -> Main.chooseThreadType(true, false, false, 100).equals("platform"));
        t.put("bursty io-bound work just below the threshold stays platform", () -> Main.chooseThreadType(true, false, false, 999).equals("platform"));
        t.put("io-bound work exactly at the threshold uses virtual threads", () -> Main.chooseThreadType(true, false, false, 1_000).equals("virtual"));
        t.put("non-blocking work stays platform", () -> Main.chooseThreadType(false, false, false, 99_999).equals("platform"));
        return t;
    }
}
