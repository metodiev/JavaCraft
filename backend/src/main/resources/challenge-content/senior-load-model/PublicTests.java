import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a single pacing user is an open model", () ->
                Main.model(5.0, true, 1).equals("OPEN")
                        && Main.model(5.0, false, 1).equals("OPEN"));
        t.put("a bounded user pool is a closed model", () ->
                Main.model(100.0, false, 10).equals("CLOSED")
                        && Main.model(200.0, false, 25).equals("CLOSED"));
        t.put("constant traffic without a cap is an open model", () ->
                Main.model(3.5, true, 0).equals("OPEN"));
        t.put("an uncapped non-constant test ramps users and is closed", () ->
                Main.model(0.5, false, 0).equals("CLOSED"));
        t.put("one hundred requests per second is too fast and is closed", () ->
                Main.model(100.0, true, 0).equals("CLOSED")
                        && Main.model(99.9, true, 0).equals("OPEN"));
        t.put("a huge rate is always closed", () ->
                Main.model(150.0, true, 50).equals("CLOSED")
                        && Main.model(1000.0, true, 1).equals("CLOSED"));
        t.put("zero and negative rates are closed even when uncapped", () ->
                Main.model(0.0, true, 0).equals("CLOSED")
                        && Main.model(-1.0, false, 1).equals("CLOSED"));
        t.put("a concurrency cap of two or more always closes the model", () ->
                Main.model(9.0, true, 2).equals("CLOSED")
                        && Main.model(0.1, false, 3).equals("CLOSED"));
        return t;
    }
}
