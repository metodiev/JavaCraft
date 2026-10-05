import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("safe method passes without tokens", () -> Main.valid(null, null, "GET"));
        t.put("head and options are safe too", () -> Main.valid(null, null, "HEAD") && Main.valid(null, null, "OPTIONS"));
        t.put("safe methods ignore a mismatched token", () -> Main.valid("token-a", "token-b", "GET"));
        t.put("state changing method with equal tokens passes", () -> Main.valid("token", "token", "POST"));
        t.put("method names are case insensitive", () -> Main.valid("token", "token", "post"));
        t.put("mismatched tokens fail", () -> !Main.valid("token-a", "token-b", "POST"));
        t.put("blank request token fails", () -> !Main.valid("token", "   ", "POST") && !Main.valid("token", "", "DELETE"));
        t.put("missing tokens fail", () -> !Main.valid(null, "token", "POST") && !Main.valid("token", null, "PATCH"));
        return t;
    }
}
