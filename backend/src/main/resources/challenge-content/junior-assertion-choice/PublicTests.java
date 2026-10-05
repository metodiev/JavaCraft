import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equality maps to isEqualTo", () -> Main.assertionFor("equality").equals("isEqualTo"));
        t.put("null maps to isNull", () -> Main.assertionFor("null").equals("isNull"));
        t.put("not-null maps to isNotNull", () -> Main.assertionFor("not-null").equals("isNotNull"));
        t.put("exception maps to isInstanceOf", () -> Main.assertionFor("exception").equals("isInstanceOf"));
        t.put("collection checks map to hasSize and isEmpty", () ->
                Main.assertionFor("collection-size").equals("hasSize")
                        && Main.assertionFor("collection-empty").equals("isEmpty"));
        t.put("an unknown check maps to unknown", () -> Main.assertionFor("vibes").equals("unknown"));
        t.put("null and upper-case checks are still handled", () ->
                Main.assertionFor(null).equals("unknown") && Main.assertionFor("EQUALITY").equals("isEqualTo"));
        return t;
    }
}
