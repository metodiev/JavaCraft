import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equality columns come first", () -> Main.indexColumns(List.of("tenant_id"), List.of(), List.of())
                .equals(List.of("tenant_id")));
        t.put("range column comes last", () -> Main.indexColumns(List.of("tenant_id"), List.of("created_at"), List.of())
                .equals(List.of("tenant_id", "created_at")));
        t.put("sort columns sit between equality and range", () -> Main.indexColumns(List.of("tenant_id"),
                List.of("created_at"), List.of("status")).equals(List.of("tenant_id", "status", "created_at")));
        t.put("empty inputs yield an empty index", () -> Main.indexColumns(List.of(), List.of(), List.of()).isEmpty());
        t.put("null inputs are treated as empty", () -> Main.indexColumns(null, null, null).isEmpty());
        t.put("input lists are not modified", () -> {
            List<String> equality = new ArrayList<>(List.of("a"));
            List<String> range = new ArrayList<>(List.of("c"));
            List<String> sort = new ArrayList<>(List.of("b"));
            Main.indexColumns(equality, range, sort);
            return equality.equals(List.of("a")) && range.equals(List.of("c")) && sort.equals(List.of("b"));
        });
        t.put("duplicates are dropped keeping the first position", () -> Main.indexColumns(List.of("a", "b"),
                List.of("c", "b"), List.of("a")).equals(List.of("a", "b", "c")));
        t.put("null entries are skipped", () -> Main.indexColumns(Arrays.asList("a", null), null, List.of())
                .equals(List.of("a")));
        return t;
    }
}
