import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static Set<String> excluded(Set<String> declared, Set<String> inherited, boolean inheritEnabled) {
        TreeSet<String> result = new TreeSet<>();
        addAll(result, declared);
        if (inheritEnabled) {
            addAll(result, inherited);
        }
        return result;
    }

    private static void addAll(TreeSet<String> target, Set<String> source) {
        if (source == null) {
            return;
        }
        for (String exclusion : source) {
            if (exclusion != null) {
                target.add(exclusion);
            }
        }
    }
}
