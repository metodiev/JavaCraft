import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class Main {
    public static Map<String, String> selectToolchains(List<String> neededReleases, Map<String, List<String>> installed) {
        Map<String, String> selection = new LinkedHashMap<>();
        if (neededReleases == null || installed == null) {
            return selection;
        }
        Set<String> needed = new LinkedHashSet<>();
        for (String release : neededReleases) {
            if (release != null) {
                needed.add(release);
            }
        }
        if (needed.isEmpty()) {
            return selection;
        }
        for (String release : needed) {
            List<String> vendors = installed.get(release);
            TreeSet<String> available = new TreeSet<>();
            if (vendors != null) {
                for (String vendor : vendors) {
                    if (vendor != null) {
                        available.add(vendor);
                    }
                }
            }
            if (!available.isEmpty()) {
                selection.put(release, available.last());
            }
        }
        return selection;
    }
}
