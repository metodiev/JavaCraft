import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a differing value is reported as changed", () -> Main.drift(
                Map.of("instance_size", "small"), Map.of("instance_size", "large"))
                .equals(List.of("changed instance_size")));
        t.put("an attribute only in the infrastructure is added", () -> Main.drift(
                Map.of(), Map.of("public_ip", "1.2.3.4")).equals(List.of("added public_ip")));
        t.put("an attribute only in the code is removed", () -> Main.drift(
                Map.of("backup", "true"), Map.of()).equals(List.of("removed backup")));
        t.put("identical maps report no drift", () -> Main.drift(
                Map.of("a", "1", "b", "2"), Map.of("b", "2", "a", "1")).isEmpty());
        t.put("all three kinds are reported sorted", () -> {
            Map<String, String> desired = new LinkedHashMap<>();
            desired.put("zeta", "1");
            desired.put("alpha", "1");
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("zeta", "2");
            actual.put("beta", "9");
            return Main.drift(desired, actual).equals(List.of("added beta", "changed zeta", "removed alpha"));
        });
        t.put("the three kinds sort as added, changed, removed", () -> {
            Map<String, String> desired = new LinkedHashMap<>();
            desired.put("removed_key", "x");
            desired.put("changed_key", "x");
            Map<String, String> actual = new LinkedHashMap<>();
            actual.put("added_key", "y");
            actual.put("changed_key", "y");
            return Main.drift(desired, actual).equals(List.of("added added_key", "changed changed_key",
                    "removed removed_key"));
        });
        t.put("a null desired map reports every actual attribute as added", () -> Main.drift(null,
                Map.of("b", "2", "a", "1")).equals(List.of("added a", "added b")));
        t.put("a null actual map reports every desired attribute as removed", () -> Main.drift(
                Map.of("b", "2", "a", "1"), null).equals(List.of("removed a", "removed b")));
        t.put("either map null with no keys reports nothing", () ->
                Main.drift(null, null).isEmpty() && Main.drift(Map.of(), null).isEmpty());
        return t;
    }
}
