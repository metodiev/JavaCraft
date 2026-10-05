import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> firstWeek(boolean javaBackground, boolean hasProductionAccess) {
        List<String> out = new ArrayList<>();
        out.add("set up the development environment");
        out.add("run the build and the test suite");
        if (!javaBackground) {
            out.add("work through the Java and framework learning path");
        }
        out.add("ship a small change to production");
        if (hasProductionAccess) {
            out.add("walk through the production runbooks and on-call basics");
        }
        out.add("meet the team and agree on a buddy");
        return out;
    }
}
