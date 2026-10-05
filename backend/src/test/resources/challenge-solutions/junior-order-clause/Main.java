import java.util.ArrayList;
import java.util.List;

public class Main {
    public static final List<String> ALLOWED_COLUMNS = List.of("id", "email", "status", "created_at", "score");

    public static String orderBy(List<String> columns, boolean descending) {
        if (columns == null || columns.isEmpty()) {
            throw new IllegalArgumentException("empty order by");
        }
        List<String> parts = new ArrayList<>();
        for (String column : columns) {
            if (column == null || !ALLOWED_COLUMNS.contains(column)) {
                throw new IllegalArgumentException("unknown column: " + column);
            }
            parts.add(column + (descending ? " DESC" : " ASC"));
        }
        return String.join(", ", parts);
    }
}
