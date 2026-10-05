import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("completed steps are compensated in reverse order", () ->
                Main.compensate(List.of("reserve-inventory", "charge-card", "ship-order"), "notify-customer")
                        .equals(List.of("ship-order", "charge-card", "reserve-inventory")));
        t.put("the failed step is never compensated", () ->
                Main.compensate(List.of("reserve-inventory", "charge-card"), "charge-card")
                        .equals(List.of("reserve-inventory")));
        t.put("the failed step is skipped even when it is not last", () ->
                Main.compensate(List.of("a", "b", "c"), "b").equals(List.of("c", "a")));
        t.put("audit steps are irreversible and skipped", () ->
                Main.compensate(List.of("reserve-inventory", "audit-log", "charge-card"), "ship")
                        .equals(List.of("charge-card", "reserve-inventory")));
        t.put("each step is compensated once at its latest position", () ->
                Main.compensate(List.of("a", "b", "a"), "x").equals(List.of("a", "b")));
        t.put("null input or nothing to compensate yields an empty list", () ->
                Main.compensate(null, "x").isEmpty() && Main.compensate(List.of("x"), "x").isEmpty());
        t.put("null entries are skipped", () ->
                Main.compensate(Arrays.asList("a", null, "b"), "x").equals(List.of("b", "a")));
        return t;
    }
}
