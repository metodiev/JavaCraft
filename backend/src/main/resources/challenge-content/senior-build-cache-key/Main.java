import java.util.List;

public class Main {
    public static String cacheKey(String taskName, List<String> inputs, String jdkVersion) {
        // TODO: fingerprint the task inputs so identical builds reuse the same key
        return "";
    }
}
