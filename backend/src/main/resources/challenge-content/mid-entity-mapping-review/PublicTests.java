import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a sound mapping reports no problems", () -> Main.problems(Map.of(
                "id", "IDENTITY",
                "tags", "LAZY collection",
                "name", "column(name)",
                "createdAt", "column(created_at)")).isEmpty());
        t.put("a missing id is reported", () -> Main.problems(Map.of("name", "column(name)"))
                .equals(List.of("Order: missing id")));
        t.put("an eager collection is reported", () -> Main.problems(Map.of(
                "id", "IDENTITY", "tags", "EAGER collection"))
                .equals(List.of("Order: collection tags should be LAZY")));
        t.put("a manually assigned id with a generated strategy is reported", () -> Main.problems(Map.of(
                "id", "IDENTITY", "pid", "assigned"))
                .equals(List.of("Order: generated id conflicts with assigned id on pid")));
        t.put("multiple problems are sorted by property",
                () -> Main.problems(Map.of("id", "IDENTITY", "tags", "EAGER collection", "orders", "EAGER collection"))
                        .equals(List.of(
                                "Order: collection orders should be LAZY",
                                "Order: collection tags should be LAZY")));
        t.put("an empty or null mapping is reported as missing id",
                () -> Main.problems(Map.of()).equals(List.of("Order: missing id"))
                        && Main.problems(null).equals(List.of("Order: missing id")));
        t.put("a lazy collection and a natural id are accepted", () -> Main.problems(Map.of(
                "id", "SEQUENCE", "items", "LAZY collection", "isbn", "assigned but not generated"))
                .isEmpty());
        return t;
    }
}
