public class Main {
    public static int compareReleases(String left, String right) {
        int[] a = parse(left);
        int[] b = parse(right);
        for (int i = 0; i < 3; i++) {
            int comparison = Integer.compare(a[i], b[i]);
            if (comparison != 0) {
                return comparison;
            }
        }
        return 0;
    }

    private static int[] parse(String version) {
        int[] components = new int[]{0, 0, 0};
        if (version == null || version.isBlank()) {
            return components;
        }
        String text = version.trim();
        if (text.startsWith("1.")) {
            text = text.substring(2);
        }
        String[] parts = text.split("[._]", -1);
        for (int i = 0; i < 3 && i < parts.length; i++) {
            components[i] = parseComponent(parts[i]);
        }
        return components;
    }

    private static int parseComponent(String part) {
        try {
            return Integer.parseInt(part);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
