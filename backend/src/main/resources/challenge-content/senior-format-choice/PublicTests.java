import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("browser clients get json", () -> Main.format(false, true, true, true).equals("JSON"));
        t.put("readable payloads stay json",
                () -> Main.format(true, true, true, false).equals("JSON"));
        t.put("low volume stays json even with schema evolution",
                () -> Main.format(false, true, false, false).equals("JSON"));
        t.put("high-volume evolution picks avro",
                () -> Main.format(false, true, true, false).equals("AVRO"));
        t.put("high-volume stable contracts pick protobuf",
                () -> Main.format(false, false, true, false).equals("PROTOBUF"));
        t.put("the browser rule beats readability and volume",
                () -> Main.format(true, false, true, true).equals("JSON"));
        t.put("evolution is ignored when the browser rule applies",
                () -> Main.format(false, false, false, true).equals("JSON"));
        return t;
    }
}
