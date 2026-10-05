import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> header, Map<String, Object> claims, long nowEpochSeconds) {
        List<String> out = new ArrayList<>();
        Object alg = header == null ? null : header.get("alg");
        if (!(alg instanceof String algName) || algName.isBlank() || algName.equalsIgnoreCase("none")) {
            out.add("alg none is not allowed");
        }
        Object exp = claims == null ? null : claims.get("exp");
        if (!(exp instanceof Number expiresAt)) {
            out.add("exp is required");
        } else if (expiresAt.longValue() <= nowEpochSeconds) {
            out.add("token is expired");
        }
        Object sub = claims == null ? null : claims.get("sub");
        if (!(sub instanceof String subject) || subject.isBlank()) {
            out.add("sub is required");
        }
        return out;
    }
}
