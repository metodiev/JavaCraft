import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a private service with timeouts only needs bounded queues", () -> Main.mandatoryControls(false, false, true).equals(List.of("bounded-queues")));
        t.put("missing timeouts add the timeout control", () -> Main.mandatoryControls(false, false, false).equals(List.of("timeouts", "bounded-queues")));
        t.put("a shared pool adds bulkheads", () -> Main.mandatoryControls(false, true, true).equals(List.of("bounded-queues", "bulkheads")));
        t.put("a public api adds rate limiting", () -> Main.mandatoryControls(true, false, true).equals(List.of("bounded-queues", "rate-limiting")));
        t.put("all risk factors add every control in order", () -> Main.mandatoryControls(true, true, false)
                .equals(List.of("timeouts", "bounded-queues", "bulkheads", "rate-limiting")));
        t.put("controls already in place are not repeated", () -> Main.mandatoryControls(true, true, true)
                .equals(List.of("bounded-queues", "bulkheads", "rate-limiting")));
        t.put("the documented order is stable across profiles", () -> Main.mandatoryControls(true, false, false)
                .equals(List.of("timeouts", "bounded-queues", "rate-limiting")));
        t.put("bounded queues are always mandatory", () -> !Main.mandatoryControls(false, false, false).isEmpty()
                && Main.mandatoryControls(true, true, true).get(0).equals("bounded-queues"));
        return t;
    }
}
