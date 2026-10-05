import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a dependency chain is sequenced in order", () ->
                Main.sequence(List.of("deploy", "build", "design"),
                        Map.of("build", Set.of("design"), "deploy", Set.of("build")))
                        .equals(List.of("design", "build", "deploy")));
        t.put("items without blockers are alphabetical", () ->
                Main.sequence(List.of("beta", "alpha"), null).equals(List.of("alpha", "beta")));
        t.put("ready items stay alphabetical around dependencies", () ->
                Main.sequence(List.of("d", "c", "b", "a"), Map.of("d", Set.of("a")))
                        .equals(List.of("a", "b", "c", "d")));
        t.put("duplicate and null items are listed once", () ->
                Main.sequence(Arrays.asList("b", null, "b", "a"), Map.of()).equals(List.of("a", "b")));
        t.put("a cycle yields an empty list", () ->
                Main.sequence(List.of("a", "b"), Map.of("a", Set.of("b"), "b", Set.of("a"))).isEmpty());
        t.put("a self dependency is a cycle", () ->
                Main.sequence(List.of("a"), Map.of("a", Set.of("a"))).isEmpty());
        t.put("blockers outside the item list are ignored", () ->
                Main.sequence(List.of("a"), Map.of("a", Set.of("ghost"))).equals(List.of("a")));
        t.put("a partial cycle discards the whole order", () ->
                Main.sequence(List.of("a", "b", "c"), Map.of("b", Set.of("c"), "c", Set.of("b"))).isEmpty());
        t.put("null or empty item lists have nothing to sequence", () ->
                Main.sequence(null, Map.of()).isEmpty() && Main.sequence(List.of(), Map.of()).isEmpty());
        return t;
    }
}
