import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("reports an artifact whose version differs from the BOM", () -> {
            Map<String, String> declared = new LinkedHashMap<>();
            declared.put("org.example:core", "1.1");
            declared.put("org.example:web", "2.0");
            Map<String, String> bom = new LinkedHashMap<>();
            bom.put("org.example:core", "1.0");
            bom.put("org.example:web", "2.0");
            return Main.misaligned(declared, bom).equals(List.of("org.example:core"));
        });
        t.put("artifacts the BOM does not manage are ignored", () -> {
            Map<String, String> declared = new LinkedHashMap<>();
            declared.put("org.example:extra", "9.9");
            return Main.misaligned(declared, Map.of("org.example:core", "1.0")).isEmpty();
        });
        t.put("the result is sorted", () -> {
            Map<String, String> declared = new LinkedHashMap<>();
            declared.put("z:z", "2");
            declared.put("a:a", "2");
            Map<String, String> bom = new LinkedHashMap<>();
            bom.put("z:z", "1");
            bom.put("a:a", "1");
            return Main.misaligned(declared, bom).equals(List.of("a:a", "z:z"));
        });
        t.put("an aligned project reports nothing", () -> Main.misaligned(
                Map.of("org.example:core", "1.0"), Map.of("org.example:core", "1.0")).isEmpty());
        t.put("null or empty inputs report nothing", () ->
                Main.misaligned(null, null).isEmpty() && Main.misaligned(Map.of(), Map.of("a:a", "1")).isEmpty());
        t.put("a missing declared version counts as misaligned", () -> {
            Map<String, String> declared = new HashMap<>();
            declared.put("a:a", null);
            return Main.misaligned(declared, Map.of("a:a", "1")).equals(List.of("a:a"));
        });
        t.put("versions are compared exactly", () -> Main.misaligned(
                Map.of("a:a", "1.0 "), Map.of("a:a", "1.0")).equals(List.of("a:a")));
        return t;
    }
}
