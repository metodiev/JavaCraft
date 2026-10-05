import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null maps have no inconsistencies", () ->
                Main.inconsistencies(null, null).isEmpty()
                        && Main.inconsistencies(Map.of("total", "orderTotal"), null).isEmpty());
        t.put("matching names are not reported", () ->
                Main.inconsistencies(Map.of("total", "Order Total"), Map.of("total", " order total "))
                        .isEmpty());
        t.put("a differing name is reported", () ->
                Main.inconsistencies(Map.of("total", "orderTotal"), Map.of("total", "Order Total"))
                        .equals(List.of("total: code uses 'orderTotal' but glossary says 'Order Total'")));
        t.put("concepts missing from the glossary are ignored", () ->
                Main.inconsistencies(Map.of("total", "orderTotal", "shipment", "shipmentDate"), Map.of())
                        .isEmpty());
        t.put("a null name is treated as empty", () ->
                Main.inconsistencies(Collections.singletonMap("total", null), Map.of("total", "Order"))
                        .equals(List.of("total: code uses '' but glossary says 'Order'"))
                        && Main.inconsistencies(Map.of("total", "Order"), Collections.singletonMap("total", null))
                                .equals(List.of("total: code uses 'Order' but glossary says ''")));
        t.put("results are sorted by concept", () ->
                Main.inconsistencies(new LinkedHashMap<>(Map.of("zeta", "shipmentDate", "alpha", "orderTotal")),
                                new LinkedHashMap<>(Map.of("zeta", "Shipment Day", "alpha", "Order Total")))
                        .equals(List.of("alpha: code uses 'orderTotal' but glossary says 'Order Total'",
                                "zeta: code uses 'shipmentDate' but glossary says 'Shipment Day'")));
        t.put("null concepts are skipped", () -> {
            Map<String, String> codeNames = new LinkedHashMap<>();
            codeNames.put(null, "mystery");
            codeNames.put("total", "orderTotal");
            return Main.inconsistencies(codeNames, Map.of("total", "Order Total")).size() == 1;
        });
        return t;
    }
}
