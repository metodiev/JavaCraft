import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> upgradeSteps(boolean usesJavaxAnnotations, boolean usesListenableFuture, boolean usesRestTemplate) {
        List<String> steps = new ArrayList<>();
        steps.add("verify Java 17+ and Jakarta EE 11 baselines");
        if (usesJavaxAnnotations) {
            steps.add("migrate javax.annotation and javax.inject usages to the jakarta packages");
        }
        if (usesListenableFuture) {
            steps.add("replace ListenableFuture with CompletableFuture");
        }
        if (usesRestTemplate) {
            steps.add("migrate RestTemplate usages to RestClient before the 7.1 deprecation");
        }
        return steps;
    }
}
