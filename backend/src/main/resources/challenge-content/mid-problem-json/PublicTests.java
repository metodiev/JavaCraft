import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("builds the five rfc 9457 members", () -> {
            Map<String, Object> p = Main.problem(404, "User 42 not found", "/users/42");
            return "about:blank".equals(p.get("type")) && "Not Found".equals(p.get("title"))
                    && Integer.valueOf(404).equals(p.get("status"))
                    && "User 42 not found".equals(p.get("detail")) && "/users/42".equals(p.get("instance"));
        });
        t.put("keys are exactly type title status detail instance", () -> Main.problem(400, "d", "/i").keySet()
                .equals(new HashSet<>(Set.of("type", "title", "status", "detail", "instance"))));
        t.put("status is carried as an integer", () -> Main.problem(422, null, null).get("status") instanceof Integer);
        t.put("common codes use their standard titles", () -> "Bad Request".equals(Main.problem(400, "d", "/i").get("title"))
                && "Conflict".equals(Main.problem(409, "d", "/i").get("title"))
                && "Unprocessable Entity".equals(Main.problem(422, "d", "/i").get("title"))
                && "Too Many Requests".equals(Main.problem(429, "d", "/i").get("title"))
                && "Internal Server Error".equals(Main.problem(500, "d", "/i").get("title"))
                && "Service Unavailable".equals(Main.problem(503, "d", "/i").get("title")));
        t.put("unlisted codes fall back to a class default", () -> "Client Error".equals(Main.problem(418, "d", "/i").get("title"))
                && "Server Error".equals(Main.problem(599, "d", "/i").get("title")));
        t.put("a null detail falls back to the title", () -> "Not Found".equals(Main.problem(404, null, "/x").get("detail")));
        t.put("a null instance becomes an empty string", () -> "".equals(Main.problem(500, "boom", null).get("instance")));
        t.put("statuses below 400 are rejected", () -> rejects(200) && rejects(399) && rejects(0));
        t.put("statuses above 599 are rejected", () -> rejects(600) && rejects(1000));
        return t;
    }

    private static boolean rejects(int status) {
        try {
            Main.problem(status, "d", "/i");
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
