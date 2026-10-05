import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Main {
    public static Map<String, List<String>> validate(String reference, int quantity, String currency) {
        Map<String, List<String>> violations = new LinkedHashMap<>();
        if (reference == null || reference.isBlank()) {
            violations.put("reference", List.of("must not be blank"));
        }
        if (quantity < 1 || quantity > 100) {
            violations.put("quantity", List.of("must be between 1 and 100"));
        }
        if (currency == null || !List.of("EUR", "USD", "CZK").contains(currency)) {
            violations.put("currency", List.of("must be one of EUR, USD, CZK"));
        }
        return violations;
    }
}
