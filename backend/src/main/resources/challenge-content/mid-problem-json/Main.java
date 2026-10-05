import java.util.*;

public class Main {
    public static Map<String, Object> problem(int status, String detail, String instance) {
        // TODO: build the RFC 9457 members with the standard title for the status
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("status", status);
        body.put("detail", detail);
        body.put("instance", instance);
        return body;
    }
}
