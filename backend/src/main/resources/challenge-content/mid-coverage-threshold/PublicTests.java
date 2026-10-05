import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a service must stay at eighty percent", () ->
                Main.thresholdFor("service") == 80);
        t.put("a controller may relax to seventy", () ->
                Main.thresholdFor("controller") == 70);
        t.put("a utility module must reach ninety", () ->
                Main.thresholdFor("utility") == 90);
        t.put("a generated module keeps the default", () ->
                Main.thresholdFor("generated") == 60);
        t.put("an unknown or missing kind keeps the default", () ->
                Main.thresholdFor("mystery") == 60 && Main.thresholdFor(null) == 60);
        t.put("case and whitespace are ignored", () ->
                Main.thresholdFor(" SERVICE ") == 80 && Main.thresholdFor("Controller") == 70);
        t.put("no threshold ever exceeds one hundred", () -> {
            boolean ok = true;
            for (String kind : List.of("service", "controller", "utility", "generated", "domain", "")) {
                ok &= Main.thresholdFor(kind) <= 100;
            }
            return ok;
        });
        return t;
    }
}
