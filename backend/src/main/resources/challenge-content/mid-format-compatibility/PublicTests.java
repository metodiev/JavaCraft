import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("identical field sets are fully compatible", () -> Main.compatibility(
                Set.of("id", "name"), Set.of("id", "name"), Set.of("id")).equals("FULL"));
        t.put("adding fields is backward compatible", () -> Main.compatibility(
                Set.of("id"), Set.of("id", "email"), Set.of("id")).equals("BACKWARD"));
        t.put("removing fields is forward compatible", () -> Main.compatibility(
                Set.of("id", "name"), Set.of("id"), Set.of("id")).equals("FORWARD"));
        t.put("adding and removing together is breaking", () -> Main.compatibility(
                Set.of("id"), Set.of("name"), Set.of()).equals("BREAKING"));
        t.put("an additive change that keeps required fields stays backward", () -> Main.compatibility(
                Set.of("id", "name"), Set.of("id", "name", "email"), Set.of("id", "name")).equals("BACKWARD"));
        t.put("dropping a required field is breaking", () -> Main.compatibility(
                Set.of("id", "name"), Set.of("id"), Set.of("name")).equals("BREAKING"));
        t.put("empty field sets are fully compatible", () -> Main.compatibility(
                Set.of(), Set.of(), Set.of()).equals("FULL"));
        t.put("null sets count as empty", () -> Main.compatibility(null, null, null).equals("FULL")
                && Main.compatibility(null, Set.of("a"), null).equals("BACKWARD"));
        t.put("a null field name is rejected", () -> {
            try { Main.compatibility(Set.of("id"), Set.of("id"), new HashSet<>(Arrays.asList("id", null))); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
