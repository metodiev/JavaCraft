import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a streaming source always recommends reactive", () ->
                Main.choose(false, true, false, 2).equals("reactive"));
        t.put("high fan-out io with reactor fluency recommends reactive", () ->
                Main.choose(true, false, true, 5000).equals("reactive"));
        t.put("fan-out of exactly 1000 recommends reactive", () ->
                Main.choose(true, false, true, 1000).equals("reactive"));
        t.put("fan-out below 1000 stays on virtual threads", () ->
                Main.choose(true, false, true, 999).equals("virtual-threads"));
        t.put("a team without reactor experience stays on virtual threads", () ->
                Main.choose(true, false, false, 5000).equals("virtual-threads"));
        t.put("cpu-bound work stays on virtual threads", () ->
                Main.choose(false, false, true, 5000).equals("virtual-threads"));
        t.put("streaming wins for a small blocking fan-out", () ->
                Main.choose(true, true, true, 10).equals("reactive"));
        t.put("a negative fan-out is rejected", () -> rejects());
        return t;
    }

    private static boolean rejects() {
        try {
            Main.choose(true, false, true, -1);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
