import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static Map<String, String> valid() {
        Map<String, String> b = new LinkedHashMap<>();
        b.put("warmupIterations", "5");
        b.put("measurementIterations", "5");
        b.put("forks", "2");
        b.put("baseline", "true");
        b.put("blackhole", "true");
        return b;
    }

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a fully configured benchmark has no problems", () ->
                Main.problems(valid()).isEmpty());
        t.put("no warmup is flagged", () -> {
            Map<String, String> b = valid();
            b.remove("warmupIterations");
            return Main.problems(b).equals(List.of("missing warmup"));
        });
        t.put("zero warmup iterations is flagged", () -> {
            Map<String, String> b = valid();
            b.put("warmupIterations", "0");
            return Main.problems(b).equals(List.of("missing warmup"));
        });
        t.put("no forks is flagged", () -> {
            Map<String, String> b = valid();
            b.put("forks", "1");
            return Main.problems(b).equals(List.of("no forks"));
        });
        t.put("dead code elimination is flagged", () -> {
            Map<String, String> b = valid();
            b.put("blackhole", "false");
            return Main.problems(b).equals(List.of("dead code elimination"));
        });
        t.put("a missing baseline is flagged", () -> {
            Map<String, String> b = valid();
            b.remove("baseline");
            return Main.problems(b).equals(List.of("no baseline"));
        });
        t.put("every problem is reported in the documented order", () -> {
            Map<String, String> b = new LinkedHashMap<>();
            b.put("warmupIterations", "0");
            b.put("forks", "0");
            b.put("blackhole", "false");
            b.put("baseline", "false");
            return Main.problems(b).equals(List.of("missing warmup", "no forks", "dead code elimination", "no baseline"));
        });
        t.put("null and empty configurations report everything", () ->
                Main.problems(null).size() == 4
                        && Main.problems(Map.of()).size() == 4);
        return t;
    }
}
