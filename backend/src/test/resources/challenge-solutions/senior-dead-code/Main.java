import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static List<String> unreachable(Set<String> declared, Set<String> referenced, Set<String> entryPoints) {
        List<String> result = new ArrayList<>();
        if (declared == null || referenced == null) {
            return result;
        }
        Set<String> entries = entryPoints == null ? Set.of() : entryPoints;
        for (String symbol : new TreeSet<>(declared)) {
            if (symbol != null && !referenced.contains(symbol) && !entries.contains(symbol)) {
                result.add(symbol);
            }
        }
        return result;
    }
}
