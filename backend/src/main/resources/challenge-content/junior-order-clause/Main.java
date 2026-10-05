import java.util.ArrayList;
import java.util.List;

public class Main {
    public static final List<String> ALLOWED_COLUMNS = List.of("id", "email", "status", "created_at", "score");

    public static String orderBy(List<String> columns, boolean descending) {
        // TODO: allowlist every column and append the direction
        List<String> parts = new ArrayList<>(columns);
        return String.join(", ", parts);
    }
}
