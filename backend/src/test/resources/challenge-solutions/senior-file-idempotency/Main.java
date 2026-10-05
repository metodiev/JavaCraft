import java.util.Map;

public class Main {
    public static boolean alreadyImported(String name, long size, Map<String, Long> imported) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("name is required");
        }
        if (size < 0) {
            throw new IllegalArgumentException("size must be non-negative");
        }
        if (imported == null) {
            throw new IllegalArgumentException("imported is required");
        }
        Long previousSize = imported.get(name);
        return previousSize != null && previousSize == size;
    }
}
