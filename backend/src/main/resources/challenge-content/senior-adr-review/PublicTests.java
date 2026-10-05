import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a complete record has no missing sections", () ->
                Main.missingSections(Map.of(
                        "context", "order events must not diverge",
                        "options", "outbox vs dual write",
                        "decision", "use an outbox",
                        "consequences", "relay must be monitored",
                        "revisit", "when throughput doubles")).isEmpty());
        t.put("missing sections are listed in canonical order", () ->
                Main.missingSections(Map.of(
                        "context", "context", "decision", "decision", "revisit", "revisit"))
                        .equals(List.of("options", "consequences")));
        t.put("blank values count as missing", () ->
                Main.missingSections(Map.of(
                        "context", "context", "options", "  ", "decision", "decision",
                        "consequences", "consequences", "revisit", "revisit"))
                        .equals(List.of("options")));
        t.put("a null or empty record misses every section", () ->
                Main.missingSections(null)
                        .equals(List.of("context", "options", "decision", "consequences", "revisit"))
                        && Main.missingSections(Map.of()).size() == 5);
        t.put("only the revisit section may be present", () ->
                Main.missingSections(Map.of("revisit", "when throughput doubles"))
                        .equals(List.of("context", "options", "decision", "consequences")));
        t.put("section keys ignore case and whitespace", () ->
                Main.missingSections(Map.of(
                        "Context", "context", " OPTIONS ", "options", "Decision", "decision",
                        "consequences", "consequences", "Revisit", "revisit")).isEmpty());
        t.put("unknown extra keys do not satisfy a section", () ->
                Main.missingSections(Map.of("status", "accepted", "date", "2026-01-01"))
                        .equals(List.of("context", "options", "decision", "consequences", "revisit")));
        t.put("a null value in a present key counts as missing", () -> {
            Map<String, String> record = new HashMap<>();
            record.put("context", null);
            return Main.missingSections(record).get(0).equals("context")
                    && Main.missingSections(record).size() == 5;
        });
        return t;
    }
}
