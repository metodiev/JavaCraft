import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("parses a simple header block", () -> {
            Map<String, String> h = Main.parse("Host: example.com\nAccept: text/html");
            return h.size() == 2 && "example.com".equals(h.get("host")) && "text/html".equals(h.get("accept"));
        });
        t.put("keys are lower-cased and trimmed", () -> {
            Map<String, String> h = Main.parse("  CONTENT-TYPE :  application/json  \r\n");
            return "application/json".equals(h.get("content-type"));
        });
        t.put("later duplicates win", () -> {
            Map<String, String> h = Main.parse("x-a: 1\nx-a: 2\nX-A: 3");
            return h.size() == 1 && "3".equals(h.get("x-a"));
        });
        t.put("values may contain colons", () -> "https://example.com:8443/a?b=c"
                .equals(Main.parse("Location: https://example.com:8443/a?b=c").get("location")));
        t.put("malformed lines are ignored", () -> {
            Map<String, String> h = Main.parse("no colon here\n: empty-name\nx: 1");
            return h.size() == 1 && "1".equals(h.get("x"));
        });
        t.put("empty values are kept", () -> {
            Map<String, String> h = Main.parse("x-empty:\ny: 2");
            return h.size() == 2 && "".equals(h.get("x-empty")) && "2".equals(h.get("y"));
        });
        t.put("blank or null input has no headers", () -> Main.parse("").isEmpty() && Main.parse(null).isEmpty());
        t.put("carriage returns are handled", () -> {
            Map<String, String> h = Main.parse("a: 1\r\nb: 2\r\n\r\n");
            return h.size() == 2 && "2".equals(h.get("b"));
        });
        return t;
    }
}
