import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static Map<String, String> parseFlags(String[] args) {
        // TODO: support --key=value and --flag, keep the last value for repeated keys,
        // and ignore tokens that are not well formed.
        return new LinkedHashMap<>();
    }
}
