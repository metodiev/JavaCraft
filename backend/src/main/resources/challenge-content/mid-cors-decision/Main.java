import java.util.*;

public class Main {
    public static List<String> headers(String origin, String method, Set<String> allowedOrigins, boolean credentials) {
        // TODO: allow only listed origins and never combine a wildcard with credentials
        List<String> headers = new ArrayList<>();
        headers.add("Access-Control-Allow-Origin: " + origin);
        return headers;
    }
}
