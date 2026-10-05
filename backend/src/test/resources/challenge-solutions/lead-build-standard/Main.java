import java.util.List;

public class Main {
    public static List<String> requiredPractices(boolean publishesLibraries, boolean regulatedDomain) {
        java.util.List<String> practices = new java.util.ArrayList<>();
        practices.add("reproducible-builds");
        practices.add("locked-dependency-versions");
        if (regulatedDomain) {
            practices.add("dependency-audit");
            practices.add("build-provenance");
        }
        if (publishesLibraries) {
            practices.add("published-metadata");
            practices.add("signed-artifacts");
        }
        return List.copyOf(practices);
    }
}
