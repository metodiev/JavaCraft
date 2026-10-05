import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("nonsensical counts are invalid", () ->
                "INVALID".equals(Main.impact(0, 1, true, false))
                        && "INVALID".equals(Main.impact(3, 0, true, false))
                        && "INVALID".equals(Main.impact(3, -1, false, false)));
        t.put("more consumers than partitions leaves idle members", () ->
                "IDLE_CONSUMERS".equals(Main.impact(2, 5, true, false))
                        && "IDLE_CONSUMERS".equals(Main.impact(2, 5, false, true)));
        t.put("cooperative with stateless consumers is minimal", () ->
                "MINIMAL".equals(Main.impact(4, 4, true, false)));
        t.put("cooperative with stateful consumers is moderate", () ->
                "MODERATE".equals(Main.impact(4, 4, true, true)));
        t.put("eager with stateless consumers is high", () ->
                "HIGH".equals(Main.impact(4, 2, false, false)));
        t.put("eager with stateful consumers is severe", () ->
                "SEVERE".equals(Main.impact(4, 2, false, true)));
        t.put("one partition and one consumer is the minimal boundary", () ->
                "MINIMAL".equals(Main.impact(1, 1, true, false)));
        t.put("exact consumer to partition match is not idle", () ->
                "SEVERE".equals(Main.impact(3, 3, false, true)));
        return t;
    }
}
