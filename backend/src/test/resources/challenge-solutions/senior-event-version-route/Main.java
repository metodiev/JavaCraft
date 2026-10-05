import java.util.List;

public class Main {
    public static String handlerFor(int eventVersion, List<Integer> supportedVersions) {
        if (eventVersion < 1 || supportedVersions == null) {
            return null;
        }
        int best = -1;
        for (Integer version : supportedVersions) {
            if (version == null || version < 1) {
                continue;
            }
            if (version == eventVersion) {
                return "v" + version;
            }
            if (version < eventVersion && version > best) {
                best = version;
            }
        }
        return best < 1 ? null : "v" + best;
    }
}
