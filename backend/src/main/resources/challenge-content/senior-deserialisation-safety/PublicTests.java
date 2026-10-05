import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an allowlisted class has no violations", () ->
                Main.violations("com.acme.Order", Set.of("com.acme")).isEmpty());
        t.put("an allowlist covers its subpackages", () ->
                Main.violations("com.acme.order.Order", Set.of("com.acme")).isEmpty());
        t.put("a similarly named package is not covered", () ->
                Main.violations("com.acmex.Order", Set.of("com.acme")).equals(List.of("package-not-allowed")));
        t.put("a class outside the allowlist is flagged", () ->
                Main.violations("org.other.Order", Set.of("com.acme")).equals(List.of("package-not-allowed")));
        t.put("a known gadget is flagged even inside an allowed package", () ->
                Main.violations("javax.naming.InitialContext", Set.of("javax.naming"))
                        .equals(List.of("dangerous-gadget")));
        t.put("the java.io namespace reports native serialisation", () ->
                Main.violations("java.io.ObjectInputStream", Set.of("com.acme"))
                        .equals(List.of("native-serialization", "package-not-allowed")));
        t.put("native serialisation is flagged even when its package is allowed", () ->
                Main.violations("java.io.File", Set.of("java.io")).equals(List.of("native-serialization")));
        t.put("a class in the default package is never allowed", () ->
                Main.violations("Order", Set.of("com.acme")).equals(List.of("package-not-allowed")));
        t.put("a null class name is rejected", () -> {
            try { Main.violations(null, Set.of("com.acme")); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
