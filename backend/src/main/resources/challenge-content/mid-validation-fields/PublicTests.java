import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a valid request has no violations", () -> Main.validate("ORD-1", 1, "EUR").isEmpty());
        t.put("a blank reference is reported", () -> Main.validate("  ", 1, "EUR").equals(Map.of("reference", List.of("must not be blank"))));
        t.put("a null reference is reported", () -> Main.validate(null, 1, "EUR").equals(Map.of("reference", List.of("must not be blank"))));
        t.put("a quantity below one is reported", () -> Main.validate("ORD-1", 0, "EUR").equals(Map.of("quantity", List.of("must be between 1 and 100"))));
        t.put("a quantity above one hundred is reported", () -> Main.validate("ORD-1", 101, "EUR").equals(Map.of("quantity", List.of("must be between 1 and 100"))));
        t.put("an unsupported currency is reported", () -> Main.validate("ORD-1", 1, "GBP").equals(Map.of("currency", List.of("must be one of EUR, USD, CZK"))));
        t.put("a null currency is reported", () -> Main.validate("ORD-1", 1, null).equals(Map.of("currency", List.of("must be one of EUR, USD, CZK"))));
        t.put("every violation is collected instead of failing fast", () -> {
            Map<String, List<String>> result = Main.validate("", 0, "GBP");
            return result.size() == 3
                    && result.get("reference").equals(List.of("must not be blank"))
                    && result.get("quantity").equals(List.of("must be between 1 and 100"))
                    && result.get("currency").equals(List.of("must be one of EUR, USD, CZK"));
        });
        t.put("keys are reported in a stable order", () -> new ArrayList<>(Main.validate("", 0, "GBP").keySet())
                .equals(List.of("reference", "quantity", "currency")));
        return t;
    }
}
