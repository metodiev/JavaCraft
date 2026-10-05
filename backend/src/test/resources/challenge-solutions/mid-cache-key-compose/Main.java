import java.util.ArrayList;
import java.util.List;

public class Main {
    public static String cacheKey(String prefix, String tenant, List<String> args) {
        List<String> parts = new ArrayList<>();
        parts.add(escape(prefix));
        parts.add(escape(tenant));
        if (args != null) {
            for (String arg : args) {
                parts.add(escape(arg));
            }
        }
        return String.join(":", parts) + ":";
    }

    private static String escape(String part) {
        if (part == null) {
            return "";
        }
        StringBuilder escaped = new StringBuilder();
        for (int i = 0; i < part.length(); i++) {
            char c = part.charAt(i);
            if (c == ':' || c == '\\') {
                escaped.append('\\');
            }
            escaped.append(c);
        }
        return escaped.toString();
    }
}
