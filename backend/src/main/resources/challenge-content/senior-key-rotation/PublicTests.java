import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("active key encrypts and decrypts", () -> Main.selectKey(5, 5, 2).equals("encrypt and decrypt"));
        t.put("previous key only decrypts", () -> Main.selectKey(4, 5, 2).equals("decrypt only"));
        t.put("last retained key only decrypts", () -> Main.selectKey(3, 5, 2).equals("decrypt only"));
        t.put("key beyond retention is retired", () -> Main.selectKey(2, 5, 2).equals("retired"));
        t.put("retention boundary is exact", () -> Main.selectKey(6, 10, 5).equals("decrypt only")
                && Main.selectKey(5, 10, 5).equals("decrypt only")
                && Main.selectKey(4, 10, 5).equals("retired"));
        t.put("single retained version keeps one older key usable", () -> Main.selectKey(4, 5, 1).equals("decrypt only")
                && Main.selectKey(3, 5, 1).equals("retired"));
        t.put("future key versions are rejected", () -> {
            try {
                Main.selectKey(6, 5, 2);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        t.put("invalid versions and retention are rejected", () -> rejects(0, 5, 2) && rejects(5, 5, 0) && rejects(-1, 5, 2));
        return t;
    }

    private static boolean rejects(int keyVersion, int activeVersion, int retainVersions) {
        try {
            Main.selectKey(keyVersion, activeVersion, retainVersions);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
