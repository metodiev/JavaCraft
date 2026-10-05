import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the only eligible candidate wins", () -> Main.partitionKey(List.of("created_at"), Map.of("created_at", 5000))
                .equals("created_at"));
        t.put("a tenant column is eligible", () -> Main.partitionKey(List.of("tenant_id"), Map.of("tenant_id", 200))
                .equals("tenant_id"));
        t.put("the highest-cardinality candidate wins", () -> Main.partitionKey(List.of("tenant_id", "status", "created_at"),
                Map.of("tenant_id", 500, "status", 5, "created_at", 9000)).equals("created_at"));
        t.put("low-cardinality columns are rejected", () -> Main.partitionKey(List.of("status", "region"),
                Map.of("status", 5, "region", 50)) == null);
        t.put("non-time, non-tenant columns are rejected", () -> Main.partitionKey(List.of("score", "email_hash"),
                Map.of("score", 10000, "email_hash", 90000)) == null);
        t.put("ties prefer the earliest candidate", () -> Main.partitionKey(List.of("tenant_id", "created_at"),
                Map.of("tenant_id", 100, "created_at", 100)).equals("tenant_id"));
        t.put("empty or null candidates yield no key", () -> Main.partitionKey(List.of(), Map.of()) == null
                && Main.partitionKey(null, null) == null);
        t.put("candidates missing from the map are ignored", () -> Main.partitionKey(List.of("created_at", "tenant_id"),
                Map.of("created_at", 700)).equals("created_at"));
        return t;
    }
}
