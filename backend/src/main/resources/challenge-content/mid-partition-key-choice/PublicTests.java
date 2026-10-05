import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("required ordering skips the random key", () ->
                "orderId".equals(Main.partitionKey("orders", false, List.of("random", "orderId"))));
        t.put("required ordering keeps a real key even with hot key risk", () ->
                "orderId".equals(Main.partitionKey("orders", true, List.of("random", "orderId", "accountId"))));
        t.put("required ordering with no safe candidate returns null", () ->
                Main.partitionKey("orders", false, List.of("random", " ", "")) == null);
        t.put("a blank ordering requirement is not a requirement", () ->
                "tenantId".equals(Main.partitionKey("  ", false, List.of("tenantId"))));
        t.put("no requirement returns the first valid candidate", () ->
                "a".equals(Main.partitionKey(null, false, List.of("a", "b"))));
        t.put("hot key risk without ordering prefers random ignoring case", () ->
                "RANDOM".equals(Main.partitionKey(null, true, List.of("tenantId", "RANDOM"))));
        t.put("hot key risk without a random candidate keeps the first key", () ->
                "tenantId".equals(Main.partitionKey(null, true, List.of("tenantId"))));
        t.put("no candidates yield no key", () ->
                Main.partitionKey(null, false, List.of()) == null
                        && Main.partitionKey("orders", true, null) == null);
        return t;
    }
}
