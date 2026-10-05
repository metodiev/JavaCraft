import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("compile always comes first", () -> Main.gateOrder(false, false).get(0).equals("compile"));
        t.put("unit tests follow compilation", () -> Main.gateOrder(false, false)
                .equals(List.of("compile", "unit tests", "package")));
        t.put("integration tests sit between unit tests and packaging", () -> Main.gateOrder(true, false)
                .equals(List.of("compile", "unit tests", "integration tests", "package")));
        t.put("a security scan runs after packaging", () -> Main.gateOrder(false, true)
                .equals(List.of("compile", "unit tests", "package", "security scan")));
        t.put("integration tests and a scan together keep cheap gates first", () -> Main.gateOrder(true, true)
                .equals(List.of("compile", "unit tests", "integration tests", "package", "security scan")));
        t.put("every gate appears exactly once", () -> {
            List<String> gates = Main.gateOrder(true, true);
            return gates.size() == 5 && new HashSet<>(gates).size() == 5;
        });
        t.put("the scan is the last gate when required", () -> {
            List<String> gates = Main.gateOrder(true, true);
            return gates.get(gates.size() - 1).equals("security scan");
        });
        return t;
    }
}
