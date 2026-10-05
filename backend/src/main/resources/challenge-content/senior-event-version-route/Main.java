import java.util.List;

public class Main {
    public static String handlerFor(int eventVersion, List<Integer> supportedVersions) {
        // TODO: prefer an exact version, otherwise fall back to the highest compatible handler
        return "v" + eventVersion;
    }
}
