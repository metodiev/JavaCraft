import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("partitions values at the threshold", () -> {
            Map<Boolean, IntSummaryStatistics> stats =
                    Main.partitionByThreshold(List.of(1, 2, 3, 4, 5), 3);
            return stats.get(true).getCount() == 3 && stats.get(false).getCount() == 2;
        });
        t.put("summarises the above group", () -> {
            IntSummaryStatistics above =
                    Main.partitionByThreshold(List.of(1, 2, 3, 4, 5), 3).get(true);
            return above.getSum() == 12 && above.getMin() == 3 && above.getMax() == 5 && above.getAverage() == 4.0;
        });
        t.put("summarises the below group", () -> {
            IntSummaryStatistics below =
                    Main.partitionByThreshold(List.of(1, 2, 3, 4, 5), 3).get(false);
            return below.getSum() == 3 && below.getMin() == 1 && below.getMax() == 2;
        });
        t.put("the threshold value belongs to the above group", () -> {
            Map<Boolean, IntSummaryStatistics> stats = Main.partitionByThreshold(List.of(10), 10);
            return stats.get(true).getCount() == 1 && stats.get(false).getCount() == 0;
        });
        t.put("ignores null entries", () -> {
            Map<Boolean, IntSummaryStatistics> stats =
                    Main.partitionByThreshold(Arrays.asList(1, null, 9, null), 5);
            return stats.get(true).getCount() == 1 && stats.get(false).getCount() == 1;
        });
        t.put("empty list gives two empty groups", () -> {
            Map<Boolean, IntSummaryStatistics> stats = Main.partitionByThreshold(List.of(), 0);
            return stats.get(true).getCount() == 0 && stats.get(false).getCount() == 0;
        });
        t.put("null list gives two empty groups", () -> {
            Map<Boolean, IntSummaryStatistics> stats = Main.partitionByThreshold(null, 0);
            return stats.get(true) != null && stats.get(false) != null
                    && stats.get(true).getCount() == 0 && stats.get(false).getCount() == 0;
        });
        t.put("negative thresholds work", () -> {
            Map<Boolean, IntSummaryStatistics> stats =
                    Main.partitionByThreshold(List.of(-5, -1, 0), -3);
            return stats.get(true).getSum() == -1 && stats.get(false).getSum() == -5;
        });
        return t;
    }
}
