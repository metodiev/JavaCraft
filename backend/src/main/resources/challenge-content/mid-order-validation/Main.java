import java.util.List;

public class Main {
    public record OrderRequest(String reference, int quantity) {}

    public static List<String> validate(OrderRequest request) {
        // TODO: return every validation message, not only the first
        return List.of();
    }
}
