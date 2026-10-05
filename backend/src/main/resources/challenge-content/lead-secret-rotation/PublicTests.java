import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("rotation starts by creating the new version", () -> Main.rotationOrder(3, true).get(0)
                .equals("create the new secret version"));
        t.put("dual write keeps both versions valid during the overlap", () -> Main.rotationOrder(3, true)
                .get(1).equals("keep both versions valid during the overlap"));
        t.put("without dual write consumers update before activation", () -> Main.rotationOrder(3, false)
                .get(1).equals("update all consumers before activating the new version"));
        t.put("several consumers roll out in batches", () -> Main.rotationOrder(3, true)
                .contains("roll the new version out to consumers in batches"));
        t.put("a single consumer rolls out without batching", () -> {
            List<String> out = Main.rotationOrder(1, true);
            return out.contains("roll the new version out to the consumer")
                    && !out.contains("roll the new version out to consumers in batches");
        });
        t.put("verification comes before revocation", () -> {
            List<String> out = Main.rotationOrder(2, false);
            return out.indexOf("verify consumers use the new version")
                    < out.indexOf("revoke the old version");
        });
        t.put("the old version is always revoked last", () -> {
            for (boolean dual : new boolean[] {true, false}) {
                List<String> out = Main.rotationOrder(4, dual);
                if (!out.get(out.size() - 1).equals("revoke the old version")) {
                    return false;
                }
            }
            return true;
        });
        t.put("every sequence has five unique steps", () -> {
            List<String> out = Main.rotationOrder(2, true);
            return out.size() == 5 && new HashSet<>(out).size() == 5;
        });
        t.put("a non-positive consumer count is rejected", () -> {
            try { Main.rotationOrder(0, true); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
