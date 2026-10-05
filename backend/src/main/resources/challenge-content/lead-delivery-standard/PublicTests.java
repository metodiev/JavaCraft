import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the base order starts with tests and ends with observing health", () -> {
            List<String> out = Main.standards(false, 1);
            return out.equals(List.of("require automated tests to pass before merge",
                    "deploy only through a reviewed pipeline",
                    "release progressively with automatic rollback",
                    "observe release health before increasing traffic"));
        });
        t.put("owning several services adds an ownership practice", () -> {
            List<String> out = Main.standards(false, 3);
            return out.size() == 5 && out.get(4).equals("define a service owner for each service")
                    && out.subList(0, 4).equals(Main.standards(false, 1));
        });
        t.put("a single service does not add the ownership practice", () ->
                !Main.standards(false, 1).contains("define a service owner for each service"));
        t.put("regulation adds audit and signing practices last", () -> {
            List<String> out = Main.standards(true, 1);
            return out.size() == 6
                    && out.get(4).equals("retain an auditable release record")
                    && out.get(5).equals("sign build artifacts");
        });
        t.put("regulation and many services combine in a fixed order", () -> {
            List<String> out = Main.standards(true, 2);
            return out.size() == 7
                    && out.get(4).equals("define a service owner for each service")
                    && out.get(5).equals("retain an auditable release record")
                    && out.get(6).equals("sign build artifacts");
        });
        t.put("every practice appears exactly once", () -> {
            List<String> out = Main.standards(true, 9);
            return new HashSet<>(out).size() == out.size();
        });
        t.put("owning no services is rejected", () -> {
            try { Main.standards(false, 0); return false; } catch (IllegalArgumentException e) { return true; }
        });
        t.put("a negative service count is rejected", () -> {
            try { Main.standards(true, -1); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
