public class Main {
    public static String sourceFor(boolean production, boolean local, boolean shortLived) {
        if (production) {
            return "MANAGED_SECRET_STORE";
        }
        if (local) {
            return "ENVIRONMENT_VARIABLES";
        }
        if (shortLived) {
            return "WORKLOAD_IDENTITY";
        }
        return "MOUNTED_FILES";
    }
}
