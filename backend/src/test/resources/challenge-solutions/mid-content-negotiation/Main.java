import java.util.*;

public class Main {
    public static String negotiate(String acceptHeader, List<String> supported) {
        if (supported == null || supported.isEmpty()) {
            throw new IllegalArgumentException("at least one representation must be supported");
        }
        List<String> types = new ArrayList<>();
        for (String candidate : supported) {
            types.add(candidate == null ? "" : candidate.trim().toLowerCase(Locale.ROOT));
        }
        if (acceptHeader == null || acceptHeader.isBlank()) {
            return supported.get(0);
        }
        List<int[]> ranges = new ArrayList<>();
        List<String> names = new ArrayList<>();
        for (String entry : acceptHeader.split(",")) {
            String[] parts = entry.split(";");
            String range = parts[0].trim().toLowerCase(Locale.ROOT);
            if (range.isEmpty()) {
                continue;
            }
            int quality = 1000;
            for (int i = 1; i < parts.length; i++) {
                String parameter = parts[i].trim();
                if (parameter.startsWith("q=")) {
                    try {
                        quality = (int) Math.round(Double.parseDouble(parameter.substring(2).trim()) * 1000);
                    } catch (NumberFormatException ignored) {
                        quality = 1000;
                    }
                }
            }
            ranges.add(new int[] {quality});
            names.add(range);
        }
        int bestIndex = -1;
        int bestQuality = 0;
        for (int i = 0; i < types.size(); i++) {
            int quality = 0;
            for (int r = 0; r < names.size(); r++) {
                if (matches(names.get(r), types.get(i))) {
                    quality = Math.max(quality, ranges.get(r)[0]);
                }
            }
            if (quality > bestQuality) {
                bestQuality = quality;
                bestIndex = i;
            }
        }
        return bestIndex < 0 ? supported.get(0) : supported.get(bestIndex);
    }

    private static boolean matches(String range, String type) {
        if (range.equals("*/*")) {
            return true;
        }
        int slash = range.indexOf('/');
        if (slash < 0) {
            return false;
        }
        String rangeType = range.substring(0, slash);
        String rangeSubtype = range.substring(slash + 1);
        int typeSlash = type.indexOf('/');
        if (typeSlash < 0) {
            return false;
        }
        return rangeType.equals(type.substring(0, typeSlash))
                && (rangeSubtype.equals("*") || rangeSubtype.equals(type.substring(typeSlash + 1)));
    }
}
