import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("clean build passes", () -> Main.gate(List.of(), 7).equals("PASS") && Main.gate(null, 7).equals("PASS"));
        t.put("reachable critical finding fails", () -> Main.gate(List.of(finding(9, true)), 7).equals("FAIL"));
        t.put("severity equal to the threshold fails", () -> Main.gate(List.of(finding(7, true)), 7).equals("FAIL"));
        t.put("unreachable critical finding warns", () -> Main.gate(List.of(finding(10, false)), 7).equals("WARN"));
        t.put("reachable low severity warns", () -> Main.gate(List.of(finding(3, true)), 7).equals("WARN"));
        t.put("severity below the threshold warns", () -> Main.gate(List.of(finding(6, true)), 7).equals("WARN"));
        t.put("missing severity counts as zero", () -> Main.gate(List.of(Map.of("reachable", true)), 7).equals("WARN"));
        t.put("invalid thresholds are rejected", () -> rejects(0) && rejects(11));
        return t;
    }

    private static Map<String, Object> finding(int severity, boolean reachable) {
        Map<String, Object> f = new LinkedHashMap<>();
        f.put("severity", severity);
        f.put("reachable", reachable);
        return f;
    }

    private static boolean rejects(int threshold) {
        try {
            Main.gate(List.of(), threshold);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
