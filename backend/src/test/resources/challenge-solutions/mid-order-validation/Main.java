import java.util.ArrayList;
import java.util.List;

public class Main {
    public record OrderRequest(String reference, int quantity) {}

    public static List<String> validate(OrderRequest request) {
        List<String> errors = new ArrayList<>();
        if (request == null) {
            errors.add("request is required");
            return errors;
        }
        if (request.reference() == null || request.reference().isBlank()) {
            errors.add("reference is required");
        }
        if (request.quantity() < 1 || request.quantity() > 100) {
            errors.add("quantity must be between 1 and 100");
        }
        return errors;
    }
}
