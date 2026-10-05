import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the batch is the budget divided by the row width",
                () -> Main.batchSize(100, 64) == 655);
        t.put("the budget is in kibibytes", () -> Main.batchSize(1024, 1) == 1);
        t.put("small rows fill the budget",
                () -> Main.batchSize(16, 8) == 512);
        t.put("the result is clamped to at most one thousand",
                () -> Main.batchSize(1, 1024) == 1000
                        && Main.batchSize(100, 64) == 655);
        t.put("the result is at least one",
                () -> Main.batchSize(4096, 1) == 1
                        && Main.batchSize(Integer.MAX_VALUE, 1) == 1);
        t.put("wide rows still produce a usable batch",
                () -> Main.batchSize(10, 1) == 102);
        t.put("non-positive inputs yield the minimum batch",
                () -> Main.batchSize(0, 64) == 1
                        && Main.batchSize(-8, 64) == 1
                        && Main.batchSize(64, 0) == 1
                        && Main.batchSize(64, -1) == 1);
        t.put("the boundary values are exact", () -> Main.batchSize(1024, 1000) == 1000
                && Main.batchSize(1025, 1000) == 999
                && Main.batchSize(2048, 1) == 1);
        return t;
    }
}
