import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        Main.Record r = new Main.Record("acme", "1");
        t.put("same tenant may read", () -> Main.mayRead("acme", r));
        t.put("other tenant may not read", () -> !Main.mayRead("globex", r));
        t.put("missing principal fails closed", () -> !Main.mayRead(null, r) && !Main.mayRead(" ", r));
        t.put("missing record or tenant fails closed", () -> !Main.mayRead("acme", null)
                && !Main.mayRead("acme", new Main.Record(null, "1")));
        t.put("tenant ids are compared exactly", () -> !Main.mayRead("ACME", r));
        t.put("admin with reason may read across tenants", () -> Main.mayAdminRead("globex", r, true, "ticket-42"));
        t.put("admin without reason is refused", () -> !Main.mayAdminRead("globex", r, true, " ")
                && !Main.mayAdminRead("globex", r, true, null));
        t.put("non-admin cannot cross tenants even with a reason", () -> !Main.mayAdminRead("globex", r, false, "ticket-42"));
        t.put("own tenant needs no admin rights", () -> Main.mayAdminRead("acme", r, false, null));
        return t;
    }
}
