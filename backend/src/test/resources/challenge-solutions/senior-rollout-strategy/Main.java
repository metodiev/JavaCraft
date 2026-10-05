public class Main {
    public static String strategy(boolean schemaChange, boolean breakingApi, int replicas) {
        if (replicas < 1) {
            throw new IllegalArgumentException("replicas must be at least 1");
        }
        if (breakingApi || replicas < 3) {
            return "BLUE_GREEN";
        }
        if (schemaChange) {
            return "CANARY";
        }
        return "ROLLING";
    }
}
