import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static final List<String> LIFECYCLE = List.of(
            "validate", "initialize", "generate-sources", "process-sources", "generate-resources",
            "process-resources", "compile", "process-classes", "generate-test-sources",
            "process-test-sources", "generate-test-resources", "process-test-resources",
            "test-compile", "process-test-classes", "test", "prepare-package", "package",
            "pre-integration-test", "integration-test", "post-integration-test", "verify",
            "install", "deploy");

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the whole default lifecycle ends with deploy", () -> Main.phasesUpTo("deploy").equals(LIFECYCLE));
        t.put("validate is the first phase", () -> Main.phasesUpTo("validate").equals(List.of("validate")));
        t.put("compile is the seventh phase", () -> Main.phasesUpTo("compile").equals(LIFECYCLE.subList(0, 7)));
        t.put("test is the fifteenth phase", () -> Main.phasesUpTo("test").equals(LIFECYCLE.subList(0, 15)));
        t.put("package is the seventeenth phase", () -> Main.phasesUpTo("package").equals(LIFECYCLE.subList(0, 17)));
        t.put("install is the twenty-second phase", () -> Main.phasesUpTo("install").equals(LIFECYCLE.subList(0, 22)));
        t.put("an unknown or empty phase yields an empty list", () ->
                Main.phasesUpTo("bogus").isEmpty() && Main.phasesUpTo("").isEmpty());
        t.put("null yields an empty list", () -> Main.phasesUpTo(null).isEmpty());
        t.put("phase names are matched case-sensitively", () ->
                Main.phasesUpTo("Deploy").isEmpty() && Main.phasesUpTo("PACKAGE").isEmpty());
        return t;
    }
}
