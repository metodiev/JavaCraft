import java.util.Set;

public class Main {
    public static boolean visible(String readerKey, Set<String> contextKeys) {
        return readerKey != null && contextKeys != null && contextKeys.contains(readerKey);
    }
}
