import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a mix of passes and failures is flaky", () ->
                Main.flaky(List.of(true, false, true)));
        t.put("all passes is not flaky", () ->
                !Main.flaky(List.of(true, true, true)));
        t.put("all failures is not flaky", () ->
                !Main.flaky(List.of(false, false)));
        t.put("a single failure after many passes is flaky", () ->
                Main.flaky(List.of(true, true, true, true, false)));
        t.put("a single pass after many failures is flaky", () ->
                Main.flaky(List.of(false, false, false, true)));
        t.put("an unjudgeable entry means the history proves nothing", () ->
                !Main.flaky(Arrays.asList(true, null)) && !Main.flaky(Arrays.asList(null, false)));
        t.put("fewer than two results cannot prove flakiness", () ->
                !Main.flaky(List.of(true)) && !Main.flaky(List.of()) && !Main.flaky(null));
        return t;
    }
}
