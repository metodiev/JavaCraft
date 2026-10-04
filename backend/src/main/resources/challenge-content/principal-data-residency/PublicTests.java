import java.util.*;
import java.util.concurrent.*;
import java.time.*;
import java.util.function.*;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        Set<String> eu = Set.of("eu-west-1", "eu-central-1");
        t.put("allowed region may store", () -> Main.mayStore("eu-west-1", eu));
        t.put("other region may not store", () -> !Main.mayStore("us-east-1", eu));
        t.put("missing region fails closed", () -> !Main.mayStore(null, eu) && !Main.mayStore(" ", eu));
        t.put("missing or empty policy fails closed", () -> !Main.mayStore("eu-west-1", null)
                && !Main.mayStore("eu-west-1", Set.of()));
        t.put("regions are compared exactly", () -> !Main.mayStore("EU-WEST-1", eu) && !Main.mayStore("eu-west", eu));
        return t;
    }
}
