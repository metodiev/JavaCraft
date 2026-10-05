import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a dependency must be extracted before its dependent", () ->
                Main.splitOrder(Map.of("core", Set.of("a", "b", "c"), "a", Set.of(), "b", Set.of("c"), "c", Set.of()))
                        .equals(List.of("a", "c", "b", "core")));
        t.put("the least coupled modules come first", () ->
                Main.splitOrder(Map.of("checkout", Set.of("payments", "inventory", "shipping"),
                                "payments", Set.of(), "inventory", Set.of(), "shipping", Set.of()))
                        .equals(List.of("inventory", "payments", "shipping", "checkout")));
        t.put("uncoupled modules are alphabetical", () ->
                Main.splitOrder(Map.of("b", Set.of(), "a", Set.of())).equals(List.of("a", "b")));
        t.put("a module referenced only as a dependency is extracted first", () ->
                Main.splitOrder(Map.of("a", Set.of("b"))).equals(List.of("b", "a")));
        t.put("a star hub is extracted after its leaves", () ->
                Main.splitOrder(Map.of("hub", Set.of("x", "y"), "x", Set.of(), "y", Set.of()))
                        .equals(List.of("x", "y", "hub")));
        t.put("mutual coupling is a cycle and has no split order", () ->
                Main.splitOrder(Map.of("a", Set.of("b"), "b", Set.of("a"))).isEmpty());
        t.put("a self reference is a cycle", () -> Main.splitOrder(Map.of("a", Set.of("a"))).isEmpty());
        t.put("null or empty maps have nothing to separate", () ->
                Main.splitOrder(null).isEmpty() && Main.splitOrder(Map.of()).isEmpty());
        return t;
    }
}
