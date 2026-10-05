import java.util.Set;

public class Main {
    public static boolean visible(String readerKey, Set<String> contextKeys) {
        // TODO: a reader sees only the keys written by its own subscription
        return contextKeys != null;
    }
}
