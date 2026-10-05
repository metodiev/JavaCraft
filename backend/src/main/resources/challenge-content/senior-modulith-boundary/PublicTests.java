import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a reference to another module's api package is allowed", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", List.of("com.acme.inventory.api.StockFacade"));
            deps.put("inventory", List.of());
            return Main.violations(deps).isEmpty();
        });
        t.put("a reference to another module's internal package is a violation", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", List.of("com.acme.billing.internal.Invoice"));
            deps.put("billing", List.of());
            return Main.violations(deps).equals(List.of("orders -> com.acme.billing.internal.Invoice"));
        });
        t.put("a type in another module's base package is its api and is allowed", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", List.of("com.acme.inventory.InventoryModule"));
            deps.put("inventory", List.of());
            return Main.violations(deps).isEmpty();
        });
        t.put("references inside the same module are always allowed", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", List.of("com.acme.orders.internal.Ledger", "com.acme.orders.api.Order"));
            return Main.violations(deps).isEmpty();
        });
        t.put("violations are sorted by source module and then by target", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("shipments", List.of("com.acme.orders.internal.Ledger"));
            deps.put("orders", List.of("com.acme.shipments.internal.Carrier", "com.acme.billing.internal.Invoice"));
            deps.put("billing", List.of());
            return Main.violations(deps).equals(List.of(
                    "orders -> com.acme.billing.internal.Invoice",
                    "orders -> com.acme.shipments.internal.Carrier",
                    "shipments -> com.acme.orders.internal.Ledger"));
        });
        t.put("references outside the application base package are ignored", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", List.of("java.time.Instant", "org.slf4j.Logger"));
            return Main.violations(deps).isEmpty();
        });
        t.put("references to modules the map does not declare are ignored", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", List.of("com.acme.shared.internal.Clock"));
            return Main.violations(deps).isEmpty();
        });
        t.put("null, blank and null list entries are ignored", () -> {
            Map<String, List<String>> deps = new LinkedHashMap<>();
            deps.put("orders", Arrays.asList(null, "  "));
            deps.put("billing", null);
            return Main.violations(deps).isEmpty();
        });
        t.put("a null dependency map returns an empty list", () -> Main.violations(null).isEmpty());
        return t;
    }
}
