import java.util.IntSummaryStatistics;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Main {
    public static Map<Boolean, IntSummaryStatistics> partitionByThreshold(List<Integer> values, int threshold) {
        if (values == null) {
            values = List.of();
        }
        return values.stream()
                .filter(value -> value != null)
                .collect(Collectors.partitioningBy(
                        value -> value >= threshold,
                        Collectors.summarizingInt(Integer::intValue)));
    }
}
