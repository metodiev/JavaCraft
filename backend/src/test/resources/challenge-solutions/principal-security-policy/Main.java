import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> controls(boolean regulatedData, boolean publicApi, int teamCount) {
        if (teamCount < 0) {
            throw new IllegalArgumentException("teamCount must not be negative");
        }
        List<String> out = new ArrayList<>();
        out.add("assign a security owner for every system");
        out.add("require two-person review for production changes");
        out.add("keep an incident response runbook up to date");
        if (regulatedData) {
            out.add("classify and retain regulated data under the data policy");
            out.add("encrypt regulated data at rest and in transit");
        }
        if (publicApi) {
            out.add("authenticate and rate limit every public endpoint");
        }
        if (teamCount >= 3) {
            out.add("run a quarterly access review");
        }
        if (teamCount >= 10) {
            out.add("fund a dedicated security engineering function");
        }
        return out;
    }
}
