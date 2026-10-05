import java.util.List;

public class Main {
    public static List<String> controls(boolean regulatedData, boolean publicApi, int teamCount) {
        // TODO: add the documented conditional controls for regulated data, public APIs and team size
        return List.of(
                "assign a security owner for every system",
                "require two-person review for production changes",
                "keep an incident response runbook up to date");
    }
}
