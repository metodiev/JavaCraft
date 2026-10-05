import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class Main {
    private static final long SLOW_QUERY_MS = 1000L;
    private static final long STATEMENT_REUSE_FACTOR = 4L;
    private static final long EAGER_COLLECTION_PERCENT = 90L;

    public static List<String> findings(Map<String, Long> stats) {
        List<String> found = new ArrayList<>();
        if (stats == null || stats.isEmpty()) {
            return found;
        }
        long slowest = value(stats, "queryExecutionMaxTime");
        if (slowest > SLOW_QUERY_MS) {
            found.add("slowest query " + slowest + "ms");
        }
        long queries = value(stats, "queryExecutionCount");
        long statements = value(stats, "prepareStatementCount");
        if (queries > 0 && statements >= queries * STATEMENT_REUSE_FACTOR) {
            found.add("statements not reused");
        }
        long entities = value(stats, "entityLoadCount");
        long collections = value(stats, "collectionFetchCount");
        if (entities > 0 && collections * 100L >= entities * EAGER_COLLECTION_PERCENT) {
            found.add("collections eagerly fetched");
        }
        Collections.sort(found);
        return found;
    }

    private static long value(Map<String, Long> stats, String key) {
        Long value = stats.get(key);
        return value == null ? 0L : value;
    }
}
