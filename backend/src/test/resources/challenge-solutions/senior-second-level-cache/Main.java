public class Main {
    private static final String NONE = "none";
    private static final String READ_ONLY = "read-only";
    private static final String READ_WRITE = "read-write";

    public static String cacheRegion(String entityName, boolean readMostly, boolean sharedAcrossNodes) {
        if (entityName == null || entityName.isBlank() || !readMostly) {
            return NONE;
        }
        return sharedAcrossNodes ? READ_ONLY : READ_WRITE;
    }
}
