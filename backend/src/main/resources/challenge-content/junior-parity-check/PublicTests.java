import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a changed value is reported", () -> Main.differences(Map.of("log.level", "DEBUG"),
                Map.of("log.level", "INFO")).equals(List.of("log.level")));
        t.put("identical maps report nothing", () -> Main.differences(Map.of("a", "1"),
                Map.of("a", "1")).isEmpty());
        t.put("a key missing from the deployment is reported", () -> Main.differences(
                Map.of("a", "1", "b", "2"), Map.of("a", "1")).equals(List.of("b")));
        t.put("keys are reported in sorted order", () -> Main.differences(
                Map.of("zeta", "1", "alpha", "2"), Map.of("zeta", "9", "alpha", "8"))
                .equals(List.of("alpha", "zeta")));
        t.put("a key present only in the deployment is reported", () -> Main.differences(Map.of("a", "1"),
                Map.of("a", "1", "new.key", "x")).equals(List.of("new.key")));
        t.put("a null local map reports every deployed key", () -> Main.differences(null,
                Map.of("b", "2", "a", "1")).equals(List.of("a", "b")));
        t.put("a null deployed map reports every local key", () -> Main.differences(
                Map.of("a", "1", "b", "2"), null).equals(List.of("a", "b")));
        t.put("both maps null report nothing", () -> Main.differences(null, null).isEmpty());
        return t;
    }
}
