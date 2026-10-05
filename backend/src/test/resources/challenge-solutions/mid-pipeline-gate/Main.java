import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> gateOrder(boolean hasIntegrationTests, boolean securityScanRequired) {
        List<String> gates = new ArrayList<>();
        gates.add("compile");
        gates.add("unit tests");
        if (hasIntegrationTests) {
            gates.add("integration tests");
        }
        gates.add("package");
        if (securityScanRequired) {
            gates.add("security scan");
        }
        return gates;
    }
}
