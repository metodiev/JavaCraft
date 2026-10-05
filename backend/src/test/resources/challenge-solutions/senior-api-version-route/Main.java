import java.util.List;

public class Main {
    public static String handler(String requestedVersion, List<String> supportedVersions, String baseline) {
        if (requestedVersion == null || requestedVersion.isBlank() || supportedVersions == null) {
            return baseline;
        }
        int[] requested = parse(requestedVersion.trim());
        String best = null;
        int[] bestParsed = null;
        for (String candidate : supportedVersions) {
            if (candidate == null) {
                continue;
            }
            int[] parsed = parse(candidate.trim());
            if (compare(parsed, requested) > 0) {
                continue;
            }
            if (bestParsed == null || compare(parsed, bestParsed) > 0) {
                best = candidate;
                bestParsed = parsed;
            }
        }
        return best == null ? baseline : best;
    }

    private static int[] parse(String version) {
        String[] parts = version.split("\\.");
        int[] numeric = new int[parts.length];
        for (int i = 0; i < parts.length; i++) {
            try {
                numeric[i] = Integer.parseInt(parts[i].trim());
            } catch (NumberFormatException ex) {
                numeric[i] = 0;
            }
        }
        return numeric;
    }

    private static int compare(int[] left, int[] right) {
        int length = Math.max(left.length, right.length);
        for (int i = 0; i < length; i++) {
            int a = i < left.length ? left[i] : 0;
            int b = i < right.length ? right[i] : 0;
            if (a != b) {
                return Integer.compare(a, b);
            }
        }
        return 0;
    }
}
