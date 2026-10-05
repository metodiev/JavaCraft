import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("key value pair is parsed", () -> {
            Map<String, String> flags = Main.parseFlags(new String[]{"--mode=fast"});
            return flags.size() == 1 && "fast".equals(flags.get("mode"));
        });
        t.put("bare flag defaults to true", () -> {
            Map<String, String> flags = Main.parseFlags(new String[]{"--verbose"});
            return flags.size() == 1 && "true".equals(flags.get("verbose"));
        });
        t.put("last value wins for repeated keys", () -> {
            Map<String, String> flags = Main.parseFlags(new String[]{"--level=1", "--level=2"});
            return flags.size() == 1 && "2".equals(flags.get("level"));
        });
        t.put("malformed tokens are ignored", () -> Main.parseFlags(null).isEmpty()
                && Main.parseFlags(new String[]{}).isEmpty()
                && Main.parseFlags(new String[]{"mode=fast", "-mode=fast", "--", "--=value", ""}).isEmpty());
        t.put("value may contain equals signs", () -> "a=b".equals(Main.parseFlags(new String[]{"--expr=a=b"}).get("expr")));
        t.put("empty value is kept", () -> {
            Map<String, String> flags = Main.parseFlags(new String[]{"--name="});
            return flags.containsKey("name") && "".equals(flags.get("name"));
        });
        t.put("valid tokens mixed with malformed ones", () -> {
            Map<String, String> flags = Main.parseFlags(new String[]{"x", "--a=1", "--", "--b", "=2"});
            return flags.size() == 2 && "1".equals(flags.get("a")) && "true".equals(flags.get("b"));
        });
        return t;
    }
}
