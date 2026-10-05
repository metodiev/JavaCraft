import java.util.Map;

public class Main {
    public static boolean alreadyImported(String name, long size, Map<String, Long> imported) {
        // TODO: treat the same name and size as an already imported file
        return imported.containsKey(name);
    }
}
