import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("sql packages require the java.sql module", () -> Main.requires(List.of("java.sql"))
                .equals(List.of("java.base", "java.sql"))
                && Main.requires(List.of("javax.sql")).equals(List.of("java.base", "java.sql")));
        t.put("concurrent utilities only need java.base", () -> Main.requires(List.of("java.util.concurrent"))
                .equals(List.of("java.base")));
        t.put("java.base is always present and always first", () -> Main.requires(null)
                .equals(List.of("java.base")) && Main.requires(List.of()).equals(List.of("java.base")));
        t.put("extra modules are sorted after java.base", () -> Main.requires(List.of("java.sql", "java.util.logging"))
                .equals(List.of("java.base", "java.logging", "java.sql")));
        t.put("subpackages resolve to their root module", () -> Main.requires(List.of("java.util.logging.handler"))
                .equals(List.of("java.base", "java.logging"))
                && Main.requires(List.of("javax.swing.table")).equals(List.of("java.base", "java.desktop")));
        t.put("duplicate packages are not repeated", () -> Main.requires(List.of("java.sql", "java.sql", "javax.sql"))
                .equals(List.of("java.base", "java.sql")));
        t.put("unknown packages fall back to java.base", () -> Main.requires(List.of("com.example.app"))
                .equals(List.of("java.base")));
        t.put("management packages map to java.management", () -> Main.requires(List.of("java.lang.management", "javax.management"))
                .equals(List.of("java.base", "java.management")));
        return t;
    }
}
