import java.util.List;
import java.util.Map;
import java.util.Set;

public class Main {
    private static final Set<String> TIME_COLUMNS = Set.of("created_at", "ordered_at", "occurred_at");
    private static final Set<String> TENANT_COLUMNS = Set.of("tenant_id", "account_id", "workspace_id");

    public static String partitionKey(List<String> candidateColumns, Map<String, Integer> cardinality) {
        if (candidateColumns == null || cardinality == null || candidateColumns.isEmpty()) {
            return null;
        }
        String best = null;
        int bestCardinality = -1;
        for (String column : candidateColumns) {
            if (column == null || !(TIME_COLUMNS.contains(column) || TENANT_COLUMNS.contains(column))) {
                continue;
            }
            Integer value = cardinality.get(column);
            if (value == null) {
                continue;
            }
            if (value > bestCardinality) {
                best = column;
                bestCardinality = value;
            }
        }
        return best;
    }
}
