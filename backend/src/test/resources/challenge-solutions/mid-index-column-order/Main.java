import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

public class Main {
    public static List<String> indexColumns(List<String> equalityColumns, List<String> rangeColumns, List<String> sortColumns) {
        LinkedHashSet<String> ordered = new LinkedHashSet<>();
        addAll(ordered, equalityColumns);
        addAll(ordered, sortColumns);
        addAll(ordered, rangeColumns);
        return new ArrayList<>(ordered);
    }

    private static void addAll(LinkedHashSet<String> target, List<String> source) {
        if (source == null) {
            return;
        }
        for (String column : source) {
            if (column != null) {
                target.add(column);
            }
        }
    }
}
