import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Main {
    public static List<String> violations(Map<String, Object> header, Map<String, Object> claims, long nowEpochSeconds) {
        // TODO: flag alg none, missing or expired exp, and a missing subject
        return new ArrayList<>();
    }
}
