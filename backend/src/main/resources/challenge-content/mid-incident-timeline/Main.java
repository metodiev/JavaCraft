import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> timeline(List<String> events) {
        // TODO: sort chronologically, breaking ties detection then mitigation then resolution
        return new ArrayList<>(events == null ? List.of() : events);
    }
}
