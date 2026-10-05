import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("nothing in place means at-least-once for now", () ->
                "AT_LEAST_ONCE".equals(Main.advise(false, false, false)));
        t.put("a transactional Kafka sink justifies transactions", () ->
                "TRANSACTIONS".equals(Main.advise(false, true, false)));
        t.put("an idempotent consumer needs no transactions", () ->
                "IDEMPOTENT_CONSUMER".equals(Main.advise(true, false, false)));
        t.put("idempotence outranks transactions when replay is harmless", () ->
                "IDEMPOTENT_CONSUMER".equals(Main.advise(true, true, false)));
        t.put("cross-system writes require an outbox", () ->
                "OUTBOX".equals(Main.advise(false, false, true)));
        t.put("cross-system writes win even with an idempotent consumer", () ->
                "OUTBOX".equals(Main.advise(true, false, true)));
        t.put("the Kafka transaction guarantee stops at cross-system writes", () ->
                "OUTBOX".equals(Main.advise(true, true, true)));
        return t;
    }
}
