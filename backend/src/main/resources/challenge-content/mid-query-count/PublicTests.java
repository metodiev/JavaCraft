import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("unbatched access is one plus N", () -> Main.totalQueries(10, 1, false, 100) == 11);
        t.put("each parent query counts once", () -> Main.totalQueries(10, 2, false, 100) == 21);
        t.put("batched access collapses child queries", () -> Main.totalQueries(10, 1, true, 5) == 3);
        t.put("a partial batch still counts", () -> Main.totalQueries(11, 1, true, 5) == 4);
        t.put("zero parents means one parent query only", () -> Main.totalQueries(0, 1, false, 10) == 1);
        t.put("zero parents with batching means one query", () -> Main.totalQueries(0, 1, true, 10) == 1);
        t.put("negative parent count is rejected", () -> rejects(-1, 1, true, 10));
        t.put("non-positive batch size is rejected when batched", () -> rejects(10, 1, true, 0) && rejects(10, 1, false, -5));
        t.put("non-positive child queries per parent is rejected", () -> rejects(10, 0, false, 10));
        return t;
    }

    private static boolean rejects(int parents, int childQueriesPerParent, boolean batched, int batchSize) {
        try { Main.totalQueries(parents, childQueriesPerParent, batched, batchSize); return false; }
        catch (IllegalArgumentException expected) { return true; }
    }
}
