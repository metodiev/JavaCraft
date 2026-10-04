public class Main {
    public static String displayName(String givenName, String familyName) {
        String given = clean(givenName);
        String family = clean(familyName);
        if (given.isEmpty() && family.isEmpty()) {
            return "Anonymous";
        }
        return (given + " " + family).trim();
    }

    public static String resolveName(String legacyName, String givenName, String familyName) {
        if (!clean(givenName).isEmpty() || !clean(familyName).isEmpty()) {
            return displayName(givenName, familyName);
        }
        String legacy = clean(legacyName);
        return legacy.isEmpty() ? "Anonymous" : legacy;
    }

    private static String clean(String value) {
        return value == null ? "" : value.trim();
    }
}
