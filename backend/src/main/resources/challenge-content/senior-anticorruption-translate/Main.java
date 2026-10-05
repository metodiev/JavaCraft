import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, Object> translate(Map<String, Object> external, Map<String, String> fieldMap) {
        // TODO: copy the mapped fields into the internal model and drop everything else
        return external == null ? new LinkedHashMap<>() : new LinkedHashMap<>(external);
    }
}
