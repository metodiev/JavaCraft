import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, String> extract(Map<String, String> switchCases) {
        // TODO: name one handler method per case key, matching the domain language
        return switchCases == null ? Map.of() : new java.util.LinkedHashMap<>(switchCases);
    }
}
