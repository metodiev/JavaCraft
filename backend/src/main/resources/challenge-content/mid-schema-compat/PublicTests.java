import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no change is fully compatible", () ->
                "FULL".equals(Main.compatibility(List.of(), List.of(), List.of()))
                        && "FULL".equals(Main.compatibility(null, null, null)));
        t.put("adding optional fields only is fully compatible", () ->
                "FULL".equals(Main.compatibility(List.of(), List.of("note"), List.of())));
        t.put("removing a field is backward compatible only", () ->
                "BACKWARD".equals(Main.compatibility(List.of("legacy"), List.of(), List.of())));
        t.put("removal with an optional addition is still backward only", () ->
                "BACKWARD".equals(Main.compatibility(List.of("a"), List.of("b"), List.of())));
        t.put("adding a required field is forward compatible only", () ->
                "FORWARD".equals(Main.compatibility(List.of(), List.of(), List.of("mandatory"))));
        t.put("required plus optional additions are forward compatible only", () ->
                "FORWARD".equals(Main.compatibility(List.of(), List.of("b"), List.of("c"))));
        t.put("removal with a required addition is compatible in neither direction", () ->
                "NONE".equals(Main.compatibility(List.of("a"), List.of(), List.of("c"))));
        t.put("all three kinds of change leave no compatibility", () ->
                "NONE".equals(Main.compatibility(List.of("a"), List.of("b"), List.of("c"))));
        return t;
    }
}
