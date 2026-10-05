import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> governanceRules(boolean publiclyConsumed, boolean regulated) {
        List<String> rules = new ArrayList<>();
        rules.add("name events in past tense with a stable envelope");
        rules.add("every topic has an accountable owning team");
        rules.add("run the registry compatibility check in CI");
        if (publiclyConsumed) {
            rules.add("enumerate external consumers before changing the schema");
        }
        if (regulated) {
            rules.add("classify payloads and enforce the retention policy");
        }
        rules.add("announce deprecations with a supported lifetime");
        return rules;
    }
}
