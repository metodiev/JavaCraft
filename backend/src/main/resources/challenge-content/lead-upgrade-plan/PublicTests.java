import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a clean codebase only needs the baseline check", () ->
                Main.upgradeSteps(false, false, false).equals(List.of("verify Java 17+ and Jakarta EE 11 baselines")));
        t.put("javax annotations are migrated to jakarta", () ->
                Main.upgradeSteps(true, false, false).equals(List.of(
                        "verify Java 17+ and Jakarta EE 11 baselines",
                        "migrate javax.annotation and javax.inject usages to the jakarta packages")));
        t.put("listenable future is replaced by completable future", () ->
                Main.upgradeSteps(false, true, false).equals(List.of(
                        "verify Java 17+ and Jakarta EE 11 baselines",
                        "replace ListenableFuture with CompletableFuture")));
        t.put("rest template is migrated to rest client", () ->
                Main.upgradeSteps(false, false, true).equals(List.of(
                        "verify Java 17+ and Jakarta EE 11 baselines",
                        "migrate RestTemplate usages to RestClient before the 7.1 deprecation")));
        t.put("all three remediations are ordered baselines first", () ->
                Main.upgradeSteps(true, true, true).equals(List.of(
                        "verify Java 17+ and Jakarta EE 11 baselines",
                        "migrate javax.annotation and javax.inject usages to the jakarta packages",
                        "replace ListenableFuture with CompletableFuture",
                        "migrate RestTemplate usages to RestClient before the 7.1 deprecation")));
        t.put("the javax migration precedes the future replacement", () -> {
            List<String> steps = Main.upgradeSteps(true, true, false);
            return steps.indexOf("migrate javax.annotation and javax.inject usages to the jakarta packages")
                    < steps.indexOf("replace ListenableFuture with CompletableFuture");
        });
        t.put("the future replacement precedes the rest client migration", () -> {
            List<String> steps = Main.upgradeSteps(false, true, true);
            return steps.indexOf("replace ListenableFuture with CompletableFuture")
                    < steps.indexOf("migrate RestTemplate usages to RestClient before the 7.1 deprecation");
        });
        t.put("the baseline check is always first", () -> {
            for (boolean a : new boolean[] {false, true}) {
                for (boolean b : new boolean[] {false, true}) {
                    for (boolean c : new boolean[] {false, true}) {
                        if (!Main.upgradeSteps(a, b, c).get(0).equals("verify Java 17+ and Jakarta EE 11 baselines")) {
                            return false;
                        }
                    }
                }
            }
            return true;
        });
        t.put("the plan is never null and contains no duplicates", () -> {
            List<String> steps = Main.upgradeSteps(true, true, true);
            return steps.size() == 4 && new HashSet<>(steps).size() == 4;
        });
        return t;
    }
}
