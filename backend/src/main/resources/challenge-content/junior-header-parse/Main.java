import java.util.*;

public class Main {
    public static Map<String, String> parse(String rawHeaders) {
        // TODO: split the block into lines and keep the last value per lower-cased key
        Map<String, String> headers = new HashMap<>();
        if (rawHeaders == null) {
            return headers;
        }
        for (String line : rawHeaders.split("\n")) {
            headers.put(line, "");
        }
        return headers;
    }
}
