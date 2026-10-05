import java.util.LinkedHashSet;
import java.util.Set;

public class Main {
    public static Set<String> invalidate(String entity, String id, Set<String> knownKeys) {
        if (entity == null || entity.isBlank() || id == null || id.isBlank() || knownKeys == null) {
            throw new IllegalArgumentException("entity, id and knownKeys are required");
        }
        String exact = entity + ":" + id;
        String nestedPrefix = exact + ":";
        String listPrefix = entity + "-list";
        Set<String> invalidated = new LinkedHashSet<>();
        for (String key : knownKeys) {
            if (key != null && (key.equals(exact)
                    || key.startsWith(nestedPrefix)
                    || key.equals(listPrefix)
                    || key.startsWith(listPrefix + ":"))) {
                invalidated.add(key);
            }
        }
        return invalidated;
    }
}
