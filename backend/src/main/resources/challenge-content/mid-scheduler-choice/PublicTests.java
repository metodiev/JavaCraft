import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("short cpu work runs on parallel", () -> Main.scheduler("cpu").equals("parallel"));
        t.put("blocking work runs on boundedElastic", () -> Main.scheduler("blocking").equals("boundedElastic"));
        t.put("serialised one-off work runs on single", () -> Main.scheduler("single").equals("single"));
        t.put("caller thread work runs on immediate", () -> Main.scheduler("immediate").equals("immediate"));
        t.put("legacy unbounded blocking uses elastic", () -> Main.scheduler("legacy").equals("elastic"));
        t.put("matching ignores case and surrounding whitespace", () -> Main.scheduler("  CPU  ").equals("parallel"));
        t.put("a null workload is rejected", () -> rejects(null));
        t.put("an unknown workload is rejected", () -> rejects("gpu"));
        return t;
    }

    private static boolean rejects(String workload) {
        try {
            Main.scheduler(workload);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
