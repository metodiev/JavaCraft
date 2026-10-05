import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("reports a removed field", () -> List.of("removed: email (string)")
                .equals(Main.breakingChanges(map("name", "string", "email", "string"), map("name", "string"))));
        t.put("reports a narrowed numeric type", () -> List.of("narrowed: id (long -> int)")
                .equals(Main.breakingChanges(map("id", "long"), map("id", "int"))));
        t.put("reports a new required field", () -> List.of("new required: phone (string!)")
                .equals(Main.breakingChanges(map("name", "string"), map("name", "string", "phone", "string!"))));
        t.put("a widened numeric type is compatible", () -> Main.breakingChanges(
                map("a", "int", "b", "float"), map("a", "long", "b", "double")).isEmpty());
        t.put("an unrelated type change is reported as changed", () -> List.of("changed: v (string -> int)")
                .equals(Main.breakingChanges(map("v", "string"), map("v", "int"))));
        t.put("an added optional field is compatible", () -> Main.breakingChanges(
                map("a", "int"), map("a", "int", "nick", "string")).isEmpty());
        t.put("required markers survive the comparison", () -> List.of("narrowed: total (long! -> int!)")
                .equals(Main.breakingChanges(map("total", "long!"), map("total", "int!"))));
        t.put("results are sorted alphabetically", () -> {
            List<String> changes = Main.breakingChanges(
                    map("b", "string", "d", "long", "z", "string"), map("d", "int", "a", "int!", "b", "int"));
            return changes.equals(new ArrayList<>(new TreeSet<>(changes))) && changes.size() == 4
                    && changes.contains("removed: z (string)");
        });
        t.put("null maps are rejected", () -> {
            try {
                Main.breakingChanges(null, map("a", "int"));
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }

    private static Map<String, String> map(String... pairs) {
        Map<String, String> result = new LinkedHashMap<>();
        for (int i = 0; i < pairs.length; i += 2) {
            result.put(pairs[i], pairs[i + 1]);
        }
        return result;
    }
}
