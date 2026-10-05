import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a shared model belongs to neither team", () ->
                Main.relationship(false, false, false).equals("SHARED_KERNEL"));
        t.put("adopting an upstream controlled model is conformist", () ->
                Main.relationship(true, true, false).equals("CONFORMIST"));
        t.put("a translation layer isolates the downstream model", () ->
                Main.relationship(true, false, true).equals("ANTICORRUPTION_LAYER")
                        && Main.relationship(false, false, true).equals("ANTICORRUPTION_LAYER"));
        t.put("upstream control without adoption is customer supplier", () ->
                Main.relationship(true, false, false).equals("CUSTOMER_SUPPLIER"));
        t.put("translation with adoption falls back to customer supplier", () ->
                Main.relationship(true, true, true).equals("CUSTOMER_SUPPLIER")
                        && Main.relationship(false, true, true).equals("CUSTOMER_SUPPLIER"));
        t.put("adoption without upstream control falls back to customer supplier", () ->
                Main.relationship(false, true, false).equals("CUSTOMER_SUPPLIER"));
        t.put("every pattern name is reachable", () -> {
            Set<String> seen = new HashSet<>();
            seen.add(Main.relationship(false, false, false));
            seen.add(Main.relationship(true, true, false));
            seen.add(Main.relationship(true, false, true));
            seen.add(Main.relationship(true, false, false));
            return seen.equals(Set.of("SHARED_KERNEL", "CONFORMIST", "ANTICORRUPTION_LAYER", "CUSTOMER_SUPPLIER"));
        });
        return t;
    }
}
