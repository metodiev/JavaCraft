import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> lockOrder(List<String> tables) {
        // TODO: produce one deterministic lock order shared by all transactions
        return new ArrayList<>(tables);
    }
}
