import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no independent deployment keeps a modular monolith even for many teams", () ->
                Main.shape(8, false, true).equals("MODULAR_MONOLITH")
                        && Main.shape(2, false, false).equals("MODULAR_MONOLITH"));
        t.put("independent deployment with strong consistency needs services", () ->
                Main.shape(3, true, true).equals("SERVICES")
                        && Main.shape(10, true, true).equals("SERVICES"));
        t.put("independent deployment with many teams and weak consistency favours events", () ->
                Main.shape(6, true, false).equals("EVENT_DRIVEN"));
        t.put("independent deployment with few teams stays with synchronous services", () ->
                Main.shape(2, true, false).equals("SERVICES"));
        t.put("the team-count boundary is five", () ->
                Main.shape(4, true, false).equals("SERVICES")
                        && Main.shape(5, true, false).equals("EVENT_DRIVEN"));
        t.put("a single team never needs distribution without independent deploys", () ->
                Main.shape(1, false, true).equals("MODULAR_MONOLITH"));
        t.put("the result is always one of the documented shapes", () -> {
            Set<String> shapes = new HashSet<>(List.of(
                    Main.shape(1, false, false), Main.shape(6, true, false), Main.shape(6, true, true)));
            return shapes.equals(Set.of("MODULAR_MONOLITH", "SERVICES", "EVENT_DRIVEN"));
        });
        t.put("a non-positive team count is rejected", () -> {
            try { Main.shape(0, true, false); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.shape(-2, false, true); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
