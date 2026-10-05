import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> rotationOrder(int consumers, boolean dualWriteSupported) {
        if (consumers < 1) {
            throw new IllegalArgumentException("consumers must be at least 1");
        }
        List<String> steps = new ArrayList<>();
        steps.add("create the new secret version");
        if (dualWriteSupported) {
            steps.add("keep both versions valid during the overlap");
        } else {
            steps.add("update all consumers before activating the new version");
        }
        if (consumers > 1) {
            steps.add("roll the new version out to consumers in batches");
        } else {
            steps.add("roll the new version out to the consumer");
        }
        steps.add("verify consumers use the new version");
        steps.add("revoke the old version");
        return steps;
    }
}
