import java.util.List;

public class Main {
    private static final List<String> PHASES = List.of(
            "validate", "initialize", "generate-sources", "process-sources", "generate-resources",
            "process-resources", "compile", "process-classes", "generate-test-sources",
            "process-test-sources", "generate-test-resources", "process-test-resources",
            "test-compile", "process-test-classes", "test", "prepare-package", "package",
            "pre-integration-test", "integration-test", "post-integration-test", "verify",
            "install", "deploy");

    public static List<String> phasesUpTo(String phase) {
        if (phase == null) {
            return List.of();
        }
        for (int i = 0; i < PHASES.size(); i++) {
            if (PHASES.get(i).equals(phase)) {
                return List.copyOf(PHASES.subList(0, i + 1));
            }
        }
        return List.of();
    }
}
