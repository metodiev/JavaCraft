import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("password storage maps to hashing", () -> Main.primitive("password-storage").equals("hashing"));
        t.put("data at rest maps to symmetric encryption", () -> Main.primitive("data-at-rest").equals("symmetric encryption"));
        t.put("message integrity maps to a mac", () -> Main.primitive("message-integrity").equals("MAC"));
        t.put("session keys map to key exchange", () -> Main.primitive("session-key").equals("key exchange"));
        t.put("null purpose is rejected", () -> rejects(null));
        t.put("unknown purpose is rejected", () -> rejects("obfuscation"));
        t.put("casing is not accepted", () -> rejects("Password-Storage"));
        return t;
    }

    private static boolean rejects(String purpose) {
        try {
            Main.primitive(purpose);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
