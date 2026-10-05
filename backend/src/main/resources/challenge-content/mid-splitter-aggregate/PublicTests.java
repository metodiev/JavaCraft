import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("matching chunks are concatenated in order", () ->
                List.of("a", "b", "c").equals(Main.recombine(
                        List.of(List.of("c1", "a"), List.of("c2", "z"), List.of("c1", "b", "c")), "c1")));
        t.put("chunks for other correlation ids are ignored", () ->
                List.of("y").equals(Main.recombine(
                        List.of(List.of("c1", "y"), List.of("c2", "x")), "c1"))
                        && Main.recombine(List.of(List.of("c2", "x")), "c1").isEmpty());
        t.put("a header-only chunk contributes no payload", () ->
                List.of("p").equals(Main.recombine(
                        List.of(List.of("c1"), List.of("c1", "p")), "c1")));
        t.put("empty input yields an empty result", () ->
                Main.recombine(List.of(), "c1").isEmpty() && Main.recombine(null, "c1").isEmpty());
        t.put("null and empty chunks are skipped", () ->
                List.of("k").equals(Main.recombine(
                        Arrays.asList(null, List.of(), List.of("c1", "k"), null), "c1")));
        t.put("matching is exact and case sensitive", () ->
                Main.recombine(List.of(List.of("C1", "x")), "c1").isEmpty()
                        && List.of("x").equals(Main.recombine(List.of(List.of("C1", "x")), "C1")));
        t.put("a null correlation id matches nothing", () ->
                Main.recombine(List.of(List.of("c1", "x")), null).isEmpty());
        return t;
    }
}
