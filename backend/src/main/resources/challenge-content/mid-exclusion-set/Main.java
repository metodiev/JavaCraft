import java.util.Set;

public class Main {
    public static Set<String> excluded(Set<String> declared, Set<String> inherited, boolean inheritEnabled) {
        // TODO: union the declared exclusions with the inherited ones when inheritance is enabled
        return declared == null ? Set.of() : declared;
    }
}
