import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a focused team has an empty metric set", () -> Main.metrics(false, false).isEmpty());
        t.put("delivery focus selects lead time and deployment frequency", () -> Main.metrics(true, false).equals(List.of(
                "lead time for change", "deployment frequency")));
        t.put("reliability focus selects change failure rate and recovery time", () -> Main.metrics(false, true).equals(List.of(
                "change failure rate", "time to restore service")));
        t.put("both focuses merge without duplicates", () -> Main.metrics(true, true).equals(List.of(
                "lead time for change", "deployment frequency", "change failure rate", "time to restore service")));
        t.put("vanity metrics are never returned", () -> {
            List<String> all = Main.metrics(true, true);
            return !all.contains("lines of code") && !all.contains("story points") && !all.contains("hours worked");
        });
        t.put("each metric appears once", () -> {
            List<String> all = Main.metrics(true, true);
            return new HashSet<>(all).size() == all.size();
        });
        return t;
    }
}
