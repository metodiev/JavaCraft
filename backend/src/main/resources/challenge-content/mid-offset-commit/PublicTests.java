import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("exactly-once wins when both guarantees are requested", () ->
                "TRANSACTIONAL".equals(Main.commitStrategy(true, true, true)));
        t.put("exactly-once alone is transactional whatever the batching", () ->
                "TRANSACTIONAL".equals(Main.commitStrategy(false, true, false))
                        && "TRANSACTIONAL".equals(Main.commitStrategy(false, true, true)));
        t.put("at-least-once with batching commits at batch boundaries", () ->
                "SYNC_AT_BATCH_BOUNDARY".equals(Main.commitStrategy(true, false, true)));
        t.put("at-least-once without batching commits per record", () ->
                "SYNC_PER_RECORD".equals(Main.commitStrategy(true, false, false)));
        t.put("at-least-once and exactly-once without batching stays transactional", () ->
                "TRANSACTIONAL".equals(Main.commitStrategy(true, true, false)));
        t.put("no guarantee requested keeps auto commit", () ->
                "AUTO_COMMIT".equals(Main.commitStrategy(false, false, true))
                        && "AUTO_COMMIT".equals(Main.commitStrategy(false, false, false)));
        return t;
    }
}
