import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        Set<String> keys = Set.of(
                "order:42", "order:42:items", "order:42:totals",
                "order:43", "order:420", "order:42items", "order-detail:42", "customer:42",
                "order-list", "order-list:tenant=acme", "order-list-summary");
        t.put("a write invalidates the key, its nested keys and list keys",
                () -> Main.invalidate("order", "42", keys).equals(Set.of(
                        "order:42", "order:42:items", "order:42:totals",
                        "order-list", "order-list:tenant=acme")));
        t.put("similar ids and other entities stay untouched",
                () -> {
                    Set<String> hit = Main.invalidate("order", "42", keys);
                    return !hit.contains("order:43") && !hit.contains("order:420")
                            && !hit.contains("order:42items") && !hit.contains("customer:42");
                });
        t.put("list prefixes stop at a dash boundary", () -> !Main.invalidate("order", "42", keys)
                .contains("order-list-summary"));
        t.put("an empty key set yields an empty result",
                () -> Main.invalidate("order", "42", Set.of()).isEmpty());
        t.put("an entity with no cached keys yields an empty result",
                () -> Main.invalidate("invoice", "7", keys).isEmpty());
        t.put("a customer write only touches customer keys",
                () -> Main.invalidate("customer", "42", keys).equals(Set.of("customer:42")));
        t.put("the input set is not modified", () -> {
            Set<String> copy = new HashSet<>(keys);
            Main.invalidate("order", "42", keys);
            return copy.equals(keys);
        });
        t.put("null or blank arguments are rejected",
                () -> rejects(null, "42", keys) && rejects("order", " ", keys) && rejects("order", "42", null));
        return t;
    }

    private static boolean rejects(String entity, String id, Set<String> keys) {
        try {
            Main.invalidate(entity, id, keys);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
