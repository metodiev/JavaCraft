import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the first delivery is false and the repeat is true", () -> {
            Set<String> seen = new HashSet<>();
            return !Main.isDuplicate(seen, "evt-1") && Main.isDuplicate(seen, "evt-1") && seen.size() == 1;
        });
        t.put("different ids are independent", () -> {
            Set<String> seen = new HashSet<>();
            return !Main.isDuplicate(seen, "a") && !Main.isDuplicate(seen, "b") && seen.size() == 2;
        });
        t.put("a null id is always a duplicate", () -> {
            Set<String> seen = new HashSet<>();
            return Main.isDuplicate(seen, null) && seen.isEmpty();
        });
        t.put("a null id does not consume a real id", () -> {
            Set<String> seen = new HashSet<>();
            return Main.isDuplicate(seen, null) && !Main.isDuplicate(seen, "a");
        });
        t.put("a null seen set is rejected", () -> {
            try {
                Main.isDuplicate(null, "a");
                return false;
            } catch (IllegalArgumentException expected) {
                return true;
            }
        });
        t.put("an id already recorded is a duplicate without re-adding", () -> {
            Set<String> seen = new HashSet<>(Set.of("a"));
            return Main.isDuplicate(seen, "a") && seen.size() == 1;
        });
        t.put("an empty set accepts the first id", () -> {
            Set<String> seen = new HashSet<>();
            return !Main.isDuplicate(seen, "first") && seen.contains("first");
        });
        return t;
    }
}
