import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, Object> projection(List<String> requestedFields, Map<String, Object> entity) {
        // TODO: copy only the requested fields that the entity has, skipping
        // nulls, and never copy a password.
        return new LinkedHashMap<>();
    }
}
