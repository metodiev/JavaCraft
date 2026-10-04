import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("joins given and family names", () -> Main.displayName("Ada", "Lovelace").equals("Ada Lovelace"));
        t.put("handles a missing family name", () -> Main.displayName("Ada", null).equals("Ada")
                && Main.displayName("Ada", " ").equals("Ada"));
        t.put("handles a missing given name", () -> Main.displayName(null, "Lovelace").equals("Lovelace"));
        t.put("falls back to Anonymous", () -> Main.displayName(null, null).equals("Anonymous")
                && Main.displayName(" ", "").equals("Anonymous"));
        t.put("new fields win over the legacy field", () -> Main.resolveName("Old Name", "Ada", "Lovelace").equals("Ada Lovelace"));
        t.put("legacy field is used for old clients", () -> Main.resolveName("  Old Name ", null, null).equals("Old Name"));
        t.put("nothing supplied is Anonymous", () -> Main.resolveName(null, null, null).equals("Anonymous")
                && Main.resolveName("", " ", " ").equals("Anonymous"));
        return t;
    }
}
