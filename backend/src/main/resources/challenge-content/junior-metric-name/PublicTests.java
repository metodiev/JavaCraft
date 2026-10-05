import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a valid dotted name has no problems", () -> Main.problems("orders.placed").isEmpty());
        t.put("digits are allowed inside segments", () -> Main.problems("http.server.requests2").isEmpty());
        t.put("uppercase letters are flagged", () -> Main.problems("Orders.placed").equals(List.of("uppercase")));
        t.put("spaces are flagged", () -> Main.problems("orders placed").equals(List.of("space")));
        t.put("characters outside the alphabet are flagged",
                () -> Main.problems("orders-placed").equals(List.of("other-character")));
        t.put("a leading or trailing dot is an empty segment",
                () -> Main.problems(".orders").equals(List.of("empty-segment"))
                        && Main.problems("orders.").equals(List.of("empty-segment")));
        t.put("consecutive dots are an empty segment",
                () -> Main.problems("orders..placed").equals(List.of("empty-segment")));
        t.put("problems are reported in the documented order",
                () -> Main.problems("Orders Placed.2x-y").equals(List.of("uppercase", "space", "other-character")));
        t.put("null and blank names are rejected", () -> rejects(null) && rejects("   "));
        return t;
    }

    private static boolean rejects(String name) {
        try {
            Main.problems(name);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
