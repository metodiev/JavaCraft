import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a healthy run reports no findings", () -> Main.findings(Map.of(
                "queryExecutionCount", 100L,
                "prepareStatementCount", 100L,
                "entityLoadCount", 1000L,
                "collectionFetchCount", 100L,
                "queryExecutionMaxTime", 50L)).isEmpty());
        t.put("an empty or null statistics map reports nothing",
                () -> Main.findings(Map.of()).isEmpty() && Main.findings(null).isEmpty());
        t.put("a slowest query over a second is reported",
                () -> Main.findings(Map.of("queryExecutionMaxTime", 1001L))
                        .equals(List.of("slowest query 1001ms")));
        t.put("one statement per execution is fine",
                () -> Main.findings(Map.of("queryExecutionCount", 100L, "prepareStatementCount", 100L)).isEmpty()
                        && !Main.findings(Map.of("queryExecutionCount", 100L, "prepareStatementCount", 100L))
                                .contains("statements not reused"));
        t.put("unreused statements are reported",
                () -> Main.findings(Map.of("queryExecutionCount", 100L, "prepareStatementCount", 900L))
                        .equals(List.of("statements not reused")));
        t.put("almost every loaded entity is fetched by a collection",
                () -> Main.findings(Map.of("entityLoadCount", 100L, "collectionFetchCount", 90L))
                        .equals(List.of("collections eagerly fetched")));
        t.put("problematic metrics are reported together in a stable order",
                () -> Main.findings(Map.of(
                        "queryExecutionCount", 10L,
                        "prepareStatementCount", 500L,
                        "queryExecutionMaxTime", 2500L,
                        "entityLoadCount", 10L,
                        "collectionFetchCount", 50L))
                        .equals(List.of(
                                "collections eagerly fetched",
                                "slowest query 2500ms",
                                "statements not reused")));
        t.put("metrics are compared on their documented thresholds", () -> {
            if (!Main.findings(Map.of("queryExecutionMaxTime", 1000L)).isEmpty()) {
                return false;
            }
            if (!Main.findings(Map.of("entityLoadCount", 100L, "collectionFetchCount", 89L)).isEmpty()) {
                return false;
            }
            if (!Main.findings(Map.of("queryExecutionCount", 100L, "prepareStatementCount", 399L)).isEmpty()) {
                return false;
            }
            return Main.findings(Map.of("queryExecutionCount", 100L, "prepareStatementCount", 400L))
                    .equals(List.of("statements not reused"));
        });
        return t;
    }
}
