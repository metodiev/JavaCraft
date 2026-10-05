import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("entries separated by equals are parsed", () -> {
            Map<String, String> props = Main.parseProperties("a=1\nb=2");
            return props.size() == 2 && "1".equals(props.get("a")) && "2".equals(props.get("b"));
        });
        t.put("colon separator is accepted and parts are trimmed", () -> {
            Map<String, String> props = Main.parseProperties("  key : value  ");
            return props.size() == 1 && "value".equals(props.get("key"));
        });
        t.put("comments and blank lines are skipped", () -> {
            Map<String, String> props = Main.parseProperties("# note\n\n   \nkey=1");
            return props.size() == 1 && "1".equals(props.get("key"));
        });
        t.put("null and empty text produce an empty map", () -> Main.parseProperties(null).isEmpty()
                && Main.parseProperties("").isEmpty());
        t.put("later separators stay in the value", () -> {
            Map<String, String> props = Main.parseProperties("url=jdbc:postgresql:db");
            return "jdbc:postgresql:db".equals(props.get("url"));
        });
        t.put("last duplicate wins", () -> "2".equals(Main.parseProperties("k=1\nk=2").get("k")));
        t.put("malformed lines are ignored", () -> Main.parseProperties("novalue\n=1\n : 2").isEmpty());
        return t;
    }
}
