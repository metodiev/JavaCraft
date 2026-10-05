import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("encode round trips through decode", () -> {
            String[] parts = Main.decode(Main.encode("2024-05-01T10:00:00Z", "u_42"));
            return parts.length == 2 && "2024-05-01T10:00:00Z".equals(parts[0]) && "u_42".equals(parts[1]);
        });
        t.put("encoded cursor is url safe and unpadded", () -> {
            String cursor = Main.encode(">>>", "\u00ff");
            return !cursor.contains("+") && !cursor.contains("/") && !cursor.contains("=") && ">>>".equals(Main.decode(cursor)[0]);
        });
        t.put("parts may contain the pipe separator", () -> {
            String[] parts = Main.decode(Main.encode("k", "a|b"));
            return parts.length == 2 && "k".equals(parts[0]) && "a|b".equals(parts[1]);
        });
        t.put("empty parts round trip", () -> {
            String[] parts = Main.decode(Main.encode("", ""));
            return parts.length == 2 && parts[0].isEmpty() && parts[1].isEmpty();
        });
        t.put("standard base64 padding is tolerated", () -> {
            String[] parts = Main.decode("a3w=");
            return parts.length == 2 && "k".equals(parts[0]) && parts[1].isEmpty();
        });
        t.put("only the first separator is used", () -> {
            String[] parts = Main.decode(Main.encode("a|b", "c"));
            return parts.length == 2 && "a".equals(parts[0]) && "b|c".equals(parts[1]);
        });
        t.put("malformed cursors decode to an empty array", () -> Main.decode("not base64!!").length == 0
                && Main.decode("YWJj").length == 0 && Main.decode(null).length == 0 && Main.decode("   ").length == 0);
        t.put("null arguments to encode are rejected", () -> {
            try {
                Main.encode(null, "x");
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
