import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a stateful bean is a prototype", () -> "prototype".equals(Main.scopeFor(true, false, false)));
        t.put("a stateless bean is a singleton", () -> "singleton".equals(Main.scopeFor(false, false, false)));
        t.put("an expensive stateless bean is still a singleton", () -> "singleton".equals(Main.scopeFor(false, true, false)));
        t.put("an expensive stateful bean is still a prototype", () -> "prototype".equals(Main.scopeFor(true, true, false)));
        t.put("a request scoped bean uses request scope", () -> "request".equals(Main.scopeFor(true, true, true)));
        t.put("request scope wins over mutable state", () -> "request".equals(Main.scopeFor(true, false, true)));
        t.put("request scope wins for stateless beans", () -> "request".equals(Main.scopeFor(false, true, true)));
        return t;
    }
}
