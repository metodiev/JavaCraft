public class Main {
    public static int compare(String left, String right) {
        int[] leftNumbers = numbers(left);
        int[] rightNumbers = numbers(right);
        int length = Math.max(leftNumbers.length, rightNumbers.length);
        for (int i = 0; i < length; i++) {
            int a = i < leftNumbers.length ? leftNumbers[i] : 0;
            int b = i < rightNumbers.length ? rightNumbers[i] : 0;
            if (a != b) {
                return a < b ? -1 : 1;
            }
        }
        String leftQualifier = qualifier(left);
        String rightQualifier = qualifier(right);
        if (leftQualifier.isEmpty() != rightQualifier.isEmpty()) {
            return leftQualifier.isEmpty() ? 1 : -1;
        }
        return Integer.signum(leftQualifier.compareTo(rightQualifier));
    }

    private static int[] numbers(String version) {
        String[] parts = core(version).split("\\.", -1);
        int[] numbers = new int[parts.length];
        for (int i = 0; i < parts.length; i++) {
            String part = parts[i].trim();
            if (part.isEmpty()) {
                throw new IllegalArgumentException("version components must not be empty: " + version);
            }
            try {
                numbers[i] = Integer.parseInt(part);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("version components must be numeric: " + version);
            }
            if (numbers[i] < 0) {
                throw new IllegalArgumentException("version components must not be negative: " + version);
            }
        }
        return numbers;
    }

    private static String core(String version) {
        validate(version);
        String trimmed = version.trim();
        int hyphen = trimmed.indexOf('-');
        return hyphen < 0 ? trimmed : trimmed.substring(0, hyphen).trim();
    }

    private static String qualifier(String version) {
        validate(version);
        String trimmed = version.trim();
        int hyphen = trimmed.indexOf('-');
        return hyphen < 0 ? "" : trimmed.substring(hyphen + 1).trim();
    }

    private static void validate(String version) {
        if (version == null || version.isBlank()) {
            throw new IllegalArgumentException("version must not be blank");
        }
    }
}
