import java.util.*;
import java.util.concurrent.Callable;
import java.util.function.Function;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("empty pipeline is the identity", () -> {
            Function<String, String> pipeline = Main.pipeline(List.of());
            return pipeline.apply("abc").equals("abc") && pipeline.apply("").equals("");
        });
        t.put("applies a single step", () -> {
            Function<String, String> pipeline = Main.pipeline(List.of(String::toUpperCase));
            return pipeline.apply("ab").equals("AB");
        });
        t.put("applies steps in the given order", () -> {
            Function<String, String> pipeline =
                    Main.pipeline(List.of(String::trim, String::toUpperCase, text -> text + "!"));
            return pipeline.apply("  hello ").equals("HELLO!");
        });
        t.put("order matters for non-commutative steps", () -> {
            Function<Integer, Integer> pipeline =
                    Main.pipeline(List.of(value -> value + 1, value -> value * 2));
            return pipeline.apply(3) == 8;
        });
        t.put("supports generic element types", () -> {
            Function<List<String>, List<String>> pipeline =
                    Main.pipeline(List.of(list -> new ArrayList<>(new LinkedHashSet<>(list))));
            return pipeline.apply(Arrays.asList("a", "b", "a")).equals(List.of("a", "b"));
        });
        t.put("the returned function can be reused", () -> {
            Function<Integer, Integer> pipeline = Main.pipeline(List.of(value -> value * value));
            return pipeline.apply(4) == 16 && pipeline.apply(5) == 25;
        });
        t.put("a null-producing step is honoured", () -> {
            Function<String, String> pipeline = Main.pipeline(List.of(text -> null));
            return pipeline.apply("x") == null;
        });
        return t;
    }
}
