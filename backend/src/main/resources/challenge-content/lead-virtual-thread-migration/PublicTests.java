import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a clean service only confirms, switches, and validates", () -> Main.migrationSteps(false, true, false)
                .equals(List.of("confirm-java21-runtime", "switch-to-virtual-executors", "load-test")));
        t.put("synchronized blocks add the pinning step", () -> Main.migrationSteps(true, true, false)
                .equals(List.of("confirm-java21-runtime", "remove-pinning", "switch-to-virtual-executors", "load-test")));
        t.put("unbounded database pools add the connection budget step", () -> Main.migrationSteps(false, false, false)
                .equals(List.of("confirm-java21-runtime", "bound-db-connections", "switch-to-virtual-executors", "load-test")));
        t.put("thread-local caches add the scoping step", () -> Main.migrationSteps(false, true, true)
                .equals(List.of("confirm-java21-runtime", "scope-threadlocals", "switch-to-virtual-executors", "load-test")));
        t.put("every risk factor produces the full ordered plan", () -> Main.migrationSteps(true, false, true)
                .equals(List.of("confirm-java21-runtime", "remove-pinning", "bound-db-connections", "scope-threadlocals", "switch-to-virtual-executors", "load-test")));
        t.put("the plan always ends with a load test", () -> Main.migrationSteps(true, false, false).get(4).equals("load-test")
                && Main.migrationSteps(false, true, true).get(3).equals("load-test"));
        t.put("the runtime check always comes first", () -> Main.migrationSteps(true, true, true).get(0).equals("confirm-java21-runtime"));
        t.put("no step is repeated", () -> new HashSet<>(Main.migrationSteps(true, false, true)).size() == 6);
        return t;
    }
}
