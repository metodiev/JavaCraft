import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("large heap with tight pause target uses zgc", () -> Main.chooseCollector(32, 10, false)
                .equals("ZGC") && Main.chooseCollector(100, 5, false).equals("ZGC"));
        t.put("large heap with relaxed pause target uses g1", () -> Main.chooseCollector(32, 200, false)
                .equals("G1") && Main.chooseCollector(64, 500, true).equals("G1"));
        t.put("small heap with relaxed pause target uses parallel", () -> Main.chooseCollector(8, 300, true)
                .equals("Parallel") && Main.chooseCollector(1, 500, false).equals("Parallel"));
        t.put("small heap with tight pause target uses g1", () -> Main.chooseCollector(8, 50, false)
                .equals("G1") && Main.chooseCollector(16, 199, true).equals("G1"));
        t.put("throughput critical workloads never get zgc", () -> {
            boolean zgc = Main.chooseCollector(64, 50, false).equals("ZGC");
            boolean g1 = Main.chooseCollector(64, 50, true).equals("G1");
            return zgc && g1;
        });
        t.put("pause targets are compared inclusively", () -> Main.chooseCollector(32, 100, false).equals("ZGC")
                && Main.chooseCollector(8, 300, false).equals("Parallel"));
        t.put("non positive heap sizes fall back to serial", () -> Main.chooseCollector(0, 10, false)
                .equals("Serial") && Main.chooseCollector(-4, 500, true).equals("Serial"));
        t.put("large means at least sixteen gigabytes", () -> Main.chooseCollector(16, 100, false).equals("ZGC")
                && Main.chooseCollector(15, 300, false).equals("Parallel"));
        return t;
    }
}
