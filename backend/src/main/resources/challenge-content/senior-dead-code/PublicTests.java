import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null inputs report nothing", () ->
                Main.unreachable(null, null, null).isEmpty()
                        && Main.unreachable(null, Set.of("a"), null).isEmpty()
                        && Main.unreachable(Set.of("a"), null, null).isEmpty());
        t.put("referenced symbols are reachable", () ->
                Main.unreachable(Set.of("a", "b"), Set.of("b"), Set.of("a")).isEmpty());
        t.put("an unreferenced symbol is dead code", () ->
                Main.unreachable(Set.of("a", "b", "c"), Set.of("b"), Set.of("a")).equals(List.of("c")));
        t.put("entry points are never dead code", () ->
                Main.unreachable(Set.of("main", "orphan"), Set.of(), Set.of("main")).equals(List.of("orphan")));
        t.put("detection is not transitive so a symbol referenced by dead code stays reachable", () ->
                Main.unreachable(Set.of("dead", "helper"), Set.of("helper"), Set.of()).equals(List.of("dead")));
        t.put("dead symbols are reported sorted", () ->
                Main.unreachable(Set.of("zebra", "alpha", "main", "yak"), Set.of("alpha"), Set.of("main"))
                        .equals(List.of("yak", "zebra")));
        t.put("extra references to undeclared symbols are ignored", () ->
                Main.unreachable(Set.of("a"), Set.of("a", "ghost"), Set.of()).isEmpty()
                        && Main.unreachable(Set.of(), Set.of("ghost"), Set.of()).isEmpty());
        t.put("an entry point that was never declared is ignored", () ->
                Main.unreachable(Set.of("a"), Set.of("a"), Set.of("ghost")).isEmpty());
        return t;
    }
}
