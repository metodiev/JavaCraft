import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the four fields keep their documented order",
                () -> new ArrayList<>(Main.auditEntry("u-1", "LOGIN", "orders", "success").keySet())
                        .equals(List.of("actor", "action", "target", "outcome")));
        t.put("a normal entry records the trimmed values",
                () -> { Map<String, Object> e = Main.auditEntry(" u-1 ", "LOGIN", "orders", "success");
                        return e.get("actor").equals("u-1") && e.get("action").equals("LOGIN")
                                && e.get("target").equals("orders") && e.get("outcome").equals("success"); });
        t.put("null and blank values become unknown", () -> { Map<String, Object> e =
                        Main.auditEntry(null, "", "   ", null);
                return e.get("actor").equals("unknown") && e.get("action").equals("unknown")
                        && e.get("target").equals("unknown") && e.get("outcome").equals("unknown"); });
        t.put("values mentioning a password, secret or token are redacted", () -> { Map<String, Object> e =
                        Main.auditEntry("u-1", "RESET", "userPassword=abc", "success");
                return e.get("target").equals("[redacted]")
                        && Main.auditEntry("u-1", "RESET", "my-secret", "success").get("target").equals("[redacted]")
                        && Main.auditEntry("u-1", "RESET", "bearer-token", "success").get("target").equals("[redacted]"); });
        t.put("a long digit run is treated as a card number", () -> {
            Map<String, Object> e = Main.auditEntry("u-1", "PAY", "card 4111111111111111 used", "success");
            return e.get("target").equals("[redacted]")
                    && Main.auditEntry("u-1", "PAY", "order 12345", "success").get("target").equals("order 12345"); });
        t.put("an unrecognised outcome becomes unknown",
                () -> Main.auditEntry("u-1", "LOGIN", "orders", "banana").get("outcome").equals("unknown")
                        && Main.auditEntry("u-1", "LOGIN", "orders", "SUCCESS").get("outcome").equals("success")
                        && Main.auditEntry("u-1", "LOGIN", "orders", "Denied").get("outcome").equals("denied"));
        t.put("the entry has exactly four fields and no raw secret leaks", () -> {
            Map<String, Object> e = Main.auditEntry("u-1", "RESET", "userPassword=hunter2", "success");
            if (e.size() != 4) {
                return false;
            }
            for (Object value : e.values()) {
                if (String.valueOf(value).contains("hunter2")) {
                    return false;
                }
            }
            return true;
        });
        return t;
    }
}
