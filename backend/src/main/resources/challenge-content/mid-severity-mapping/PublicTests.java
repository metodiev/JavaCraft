import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no findings passes", () ->
                Main.gate(List.of(), 0).equals("PASS"));
        t.put("minor and info findings only warn", () ->
                Main.gate(List.of("minor", "info", "minor"), 0).equals("WARN"));
        t.put("a critical finding fails whatever else is listed", () ->
                Main.gate(List.of("minor", "critical"), 0).equals("FAIL")
                        && Main.gate(List.of("weird", "critical"), 0).equals("FAIL")
                        && Main.gate(List.of("critical", "weird"), 0).equals("FAIL"));
        t.put("a vulnerability finding fails", () ->
                Main.gate(List.of("vulnerability"), 0).equals("FAIL"));
        t.put("a blocker fails only above the threshold", () ->
                Main.gate(List.of("blocker"), 1).equals("WARN")
                        && Main.gate(List.of("blocker"), 0).equals("FAIL"));
        t.put("blockers are counted together", () ->
                Main.gate(List.of("blocker", "info", "blocker"), 3).equals("WARN")
                        && Main.gate(List.of("blocker", "info", "blocker"), 2).equals("WARN")
                        && Main.gate(List.of("blocker", "info", "blocker"), 1).equals("FAIL"));
        t.put("severity names ignore case and surrounding whitespace", () ->
                Main.gate(List.of(" CRITICAL "), 0).equals("FAIL")
                        && Main.gate(List.of("Minor"), 0).equals("WARN"));
        t.put("an unrecognised or null input warns instead of failing", () ->
                Main.gate(List.of("mystery"), 0).equals("WARN")
                        && Main.gate(null, 0).equals("WARN")
                        && Main.gate(Arrays.asList("minor", null), 0).equals("WARN"));
        return t;
    }
}
