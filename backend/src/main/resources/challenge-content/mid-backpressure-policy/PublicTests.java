import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("lossless pipelines always buffer", () -> Main.policy(true, true, true).equals("BUFFER")
                && Main.policy(false, true, false).equals("BUFFER"));
        t.put("overflow that may not be dropped fails fast", () -> Main.policy(false, false, true).equals("ERROR")
                && Main.policy(false, false, false).equals("ERROR"));
        t.put("a slow droppable consumer keeps the newest items", () -> Main.policy(true, false, true).equals("DROP_OLDEST"));
        t.put("a fast droppable consumer drops the newest item", () -> Main.policy(true, false, false).equals("DROP_LATEST"));
        t.put("lossless wins over a slow consumer", () -> Main.policy(true, true, true).equals("BUFFER"));
        t.put("lossless wins even when drops are allowed", () -> Main.policy(true, true, false).equals("BUFFER"));
        return t;
    }
}
