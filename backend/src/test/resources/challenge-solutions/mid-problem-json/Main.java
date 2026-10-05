import java.util.*;

public class Main {
    private static final Map<Integer, String> TITLES = Map.ofEntries(
            Map.entry(400, "Bad Request"),
            Map.entry(401, "Unauthorized"),
            Map.entry(403, "Forbidden"),
            Map.entry(404, "Not Found"),
            Map.entry(409, "Conflict"),
            Map.entry(422, "Unprocessable Entity"),
            Map.entry(429, "Too Many Requests"),
            Map.entry(500, "Internal Server Error"),
            Map.entry(503, "Service Unavailable"));

    public static Map<String, Object> problem(int status, String detail, String instance) {
        if (status < 400 || status > 599) {
            throw new IllegalArgumentException("problem responses describe errors, got " + status);
        }
        String title = TITLES.get(status);
        if (title == null) {
            title = status < 500 ? "Client Error" : "Server Error";
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("type", "about:blank");
        body.put("title", title);
        body.put("status", status);
        body.put("detail", detail == null ? title : detail);
        body.put("instance", instance == null ? "" : instance);
        return body;
    }
}
