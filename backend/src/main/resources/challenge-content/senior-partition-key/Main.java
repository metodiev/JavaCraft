import java.util.List;
import java.util.Map;

public class Main {
    public static String partitionKey(List<String> candidateColumns, Map<String, Integer> cardinality) {
        // TODO: require the highest-cardinality time or tenant column
        return candidateColumns.isEmpty() ? null : candidateColumns.get(0);
    }
}
