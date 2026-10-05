import java.util.List;

public class Main {
    public static String handler(String requestedVersion, List<String> supportedVersions, String baseline) {
        // TODO: pick the highest supported version not above the request, baseline when none match
        return baseline;
    }
}
