import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> lockOrder(List<String> tables) {
        if (tables == null) {
            throw new IllegalArgumentException("tables are required");
        }
        List<String> ordered = new ArrayList<>();
        for (String table : tables) {
            if (table == null) {
                throw new IllegalArgumentException("table name is required");
            }
            ordered.add(table);
        }
        ordered.sort(String::compareTo);
        return ordered;
    }
}
