import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    private static final String PASSWORD_FIELD = "password";

    public static Map<String, Object> projection(List<String> requestedFields, Map<String, Object> entity) {
        Map<String, Object> dto = new LinkedHashMap<>();
        if (requestedFields == null || entity == null) {
            return dto;
        }
        for (String field : requestedFields) {
            if (field == null || field.equals(PASSWORD_FIELD) || dto.containsKey(field)) {
                continue;
            }
            Object value = entity.get(field);
            if (value != null) {
                dto.put(field, value);
            }
        }
        return dto;
    }
}
