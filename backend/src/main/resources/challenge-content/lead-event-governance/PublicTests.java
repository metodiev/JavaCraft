import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static final String ENVELOPE = "name events in past tense with a stable envelope";
    private static final String OWNER = "every topic has an accountable owning team";
    private static final String REGISTRY = "run the registry compatibility check in CI";
    private static final String CONSUMERS = "enumerate external consumers before changing the schema";
    private static final String CLASSIFICATION = "classify payloads and enforce the retention policy";
    private static final String DEPRECATION = "announce deprecations with a supported lifetime";

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an internal unregulated event keeps the base rules", () ->
                List.of(ENVELOPE, OWNER, REGISTRY, DEPRECATION).equals(Main.governanceRules(false, false)));
        t.put("a public event adds consumer enumeration after the base rules", () ->
                List.of(ENVELOPE, OWNER, REGISTRY, CONSUMERS, DEPRECATION)
                        .equals(Main.governanceRules(true, false)));
        t.put("a regulated event adds classification after the base rules", () ->
                List.of(ENVELOPE, OWNER, REGISTRY, CLASSIFICATION, DEPRECATION)
                        .equals(Main.governanceRules(false, true)));
        t.put("public and regulated events keep both extra rules in order", () ->
                List.of(ENVELOPE, OWNER, REGISTRY, CONSUMERS, CLASSIFICATION, DEPRECATION)
                        .equals(Main.governanceRules(true, true)));
        t.put("deprecation is always the final rule", () ->
                Main.governanceRules(false, false).get(3).equals(DEPRECATION)
                        && Main.governanceRules(true, true).get(5).equals(DEPRECATION));
        t.put("the base rules always come first", () ->
                Main.governanceRules(true, true).subList(0, 3).equals(List.of(ENVELOPE, OWNER, REGISTRY)));
        return t;
    }
}
