import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> fields(String row) {
        if (row == null || row.isBlank()) {
            throw new IllegalArgumentException("row must not be blank");
        }
        List<String> fields = new ArrayList<>();
        for (String field : row.split(",", -1)) {
            String trimmed = field.trim();
            if (trimmed.isEmpty()) {
                throw new IllegalArgumentException("fields must not be empty");
            }
            fields.add(trimmed);
        }
        return fields;
    }
}
