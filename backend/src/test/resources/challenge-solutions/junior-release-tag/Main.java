import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

public class Main {
    private static final Pattern TAG = Pattern.compile("^v?(\\d+\\.\\d+\\.\\d+)(?:\\+([^+]+))?$");

    public static Map<String, String> parse(String tag) {
        if (tag == null) {
            return Map.of();
        }
        var matcher = TAG.matcher(tag.trim());
        if (!matcher.matches()) {
            return Map.of();
        }
        Map<String, String> result = new LinkedHashMap<>();
        result.put("version", matcher.group(1));
        result.put("build", matcher.group(2) == null ? "" : matcher.group(2));
        return result;
    }
}
