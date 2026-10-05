import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("loss-tolerant work sheds load", () -> Main.rejectionPolicy(500, true, 100).equals("shed"));
        t.put("a tight latency budget with a deep queue sheds load", () -> Main.rejectionPolicy(100, false, 500).equals("shed"));
        t.put("loss-intolerant work with a roomy queue evicts the oldest", () -> Main.rejectionPolicy(500, false, 300).equals("evict-oldest"));
        t.put("a shallow queue blocks for space", () -> Main.rejectionPolicy(100, false, 10).equals("block"));
        t.put("the deep-queue threshold is exclusive", () -> Main.rejectionPolicy(100, false, 200).equals("block"));
        t.put("a budget exactly at the threshold is not tight", () -> Main.rejectionPolicy(200, false, 201).equals("evict-oldest"));
        t.put("generous budget with loss tolerance still sheds", () -> Main.rejectionPolicy(5_000, true, 5).equals("shed"));
        t.put("a zero-latency budget with a shallow queue blocks", () -> Main.rejectionPolicy(0, false, 10).equals("block"));
        return t;
    }
}
