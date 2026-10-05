import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("create returns created", () -> Main.statusFor("create") == 201);
        t.put("read returns ok", () -> Main.statusFor("read") == 200);
        t.put("delete returns no content", () -> Main.statusFor("delete") == 204);
        t.put("accept returns accepted", () -> Main.statusFor("accept") == 202);
        t.put("actions are case-insensitive and trimmed", () -> Main.statusFor("  Create ") == 201 && Main.statusFor("READ") == 200);
        t.put("unknown action is rejected", () -> rejects("publish"));
        t.put("blank action is rejected", () -> rejects("   "));
        t.put("null action is rejected", () -> rejects(null));
        return t;
    }

    private static boolean rejects(String action) {
        try {
            Main.statusFor(action);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
