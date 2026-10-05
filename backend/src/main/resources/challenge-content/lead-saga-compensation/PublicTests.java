import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("completed steps are compensated in reverse", () ->
                List.of("ship", "charge", "reserve")
                        .equals(Main.compensationOrder(List.of("reserve", "charge", "ship"))));
        t.put("read-only query steps are skipped", () ->
                List.of("charge", "reserve")
                        .equals(Main.compensationOrder(List.of("query:inventory", "reserve", "query:price", "charge"))));
        t.put("the query prefix is matched ignoring case", () ->
                List.of("b").equals(Main.compensationOrder(List.of("b", "Query:ledger"))));
        t.put("a single step reverses to itself", () ->
                List.of("reserve").equals(Main.compensationOrder(List.of("reserve"))));
        t.put("no completed steps means no compensations", () ->
                Main.compensationOrder(List.of()).isEmpty() && Main.compensationOrder(null).isEmpty());
        t.put("null and blank entries are skipped", () ->
                List.of("b", "a").equals(Main.compensationOrder(Arrays.asList("a", null, " ", "b"))));
        t.put("repeated steps are each compensated", () ->
                List.of("a", "b", "a").equals(Main.compensationOrder(List.of("a", "b", "a"))));
        return t;
    }
}
