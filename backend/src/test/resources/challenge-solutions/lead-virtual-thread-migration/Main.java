import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> migrationSteps(boolean usesSynchronizedBlocks, boolean poolsBoundedAtDb, boolean reliesOnThreadLocalCaches) {
        List<String> steps = new ArrayList<>();
        steps.add("confirm-java21-runtime");
        if (usesSynchronizedBlocks) {
            steps.add("remove-pinning");
        }
        if (!poolsBoundedAtDb) {
            steps.add("bound-db-connections");
        }
        if (reliesOnThreadLocalCaches) {
            steps.add("scope-threadlocals");
        }
        steps.add("switch-to-virtual-executors");
        steps.add("load-test");
        return steps;
    }
}
