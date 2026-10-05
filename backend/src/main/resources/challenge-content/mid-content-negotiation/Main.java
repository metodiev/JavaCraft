import java.util.List;

public class Main {
    public static String negotiate(String acceptHeader, List<String> supported) {
        // TODO: score the accepted types and pick the supported type with the highest quality
        return supported.get(0);
    }
}
