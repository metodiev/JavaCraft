import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("describes a successful outcome", () ->
                Main.Outcome.describe(new Main.Outcome.Ok("saved")).equals("ok: saved"));
        t.put("describes a failed outcome", () ->
                Main.Outcome.describe(new Main.Outcome.Failed("timeout")).equals("failed: timeout"));
        t.put("describes a null value on success", () ->
                Main.Outcome.describe(new Main.Outcome.Ok(null)).equals("ok: (none)"));
        t.put("describes a blank reason on failure", () ->
                Main.Outcome.describe(new Main.Outcome.Failed("  ")).equals("failed: (none)"));
        t.put("describes a null outcome", () ->
                Main.Outcome.describe(null).equals("unknown outcome"));
        t.put("the outcome interface is sealed", () -> Main.Outcome.class.isSealed());
        t.put("only Ok and Failed are permitted", () -> {
            Class<?>[] permitted = Main.Outcome.class.getPermittedSubclasses();
            return permitted != null
                    && permitted.length == 2
                    && Set.of(permitted[0].getSimpleName(), permitted[1].getSimpleName())
                            .equals(Set.of("Ok", "Failed"));
        });
        t.put("permitted types are records carrying one component", () ->
                Main.Outcome.Ok.class.isRecord()
                        && Main.Outcome.Failed.class.isRecord()
                        && Main.Outcome.Ok.class.getRecordComponents().length == 1
                        && Main.Outcome.Failed.class.getRecordComponents().length == 1);
        return t;
    }
}
