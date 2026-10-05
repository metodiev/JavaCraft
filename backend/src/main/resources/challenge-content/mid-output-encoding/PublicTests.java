import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null encodes to empty", () -> Main.encode(null).isEmpty());
        t.put("plain text is unchanged", () -> Main.encode("Hello, world").equals("Hello, world"));
        t.put("ampersand is escaped", () -> Main.encode("&").equals("&amp;"));
        t.put("angle brackets are escaped", () -> Main.encode("<script>").equals("&lt;script&gt;"));
        t.put("double quote is escaped", () -> Main.encode("\"quoted\"").equals("&quot;quoted&quot;"));
        t.put("single quote is escaped", () -> Main.encode("it's").equals("it&#39;s"));
        t.put("markup sample is fully escaped", () -> Main.encode("<a href=\"x\">Tom & Jerry's</a>")
                .equals("&lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&#39;s&lt;/a&gt;"));
        t.put("already escaped input is escaped again", () -> Main.encode("&amp;").equals("&amp;amp;"));
        t.put("text without special characters is untouched", () -> Main.encode("select 1 + 1").equals("select 1 + 1"));
        return t;
    }
}
