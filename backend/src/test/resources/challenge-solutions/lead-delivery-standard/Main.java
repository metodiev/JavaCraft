import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> standards(boolean regulated, int servicesOwned) {
        if (servicesOwned < 1) {
            throw new IllegalArgumentException("servicesOwned must be at least 1");
        }
        List<String> result = new ArrayList<>();
        result.add("require automated tests to pass before merge");
        result.add("deploy only through a reviewed pipeline");
        result.add("release progressively with automatic rollback");
        result.add("observe release health before increasing traffic");
        if (servicesOwned > 1) {
            result.add("define a service owner for each service");
        }
        if (regulated) {
            result.add("retain an auditable release record");
            result.add("sign build artifacts");
        }
        return result;
    }
}
