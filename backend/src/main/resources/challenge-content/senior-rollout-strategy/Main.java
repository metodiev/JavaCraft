public class Main {
    public static String strategy(boolean schemaChange, boolean breakingApi, int replicas) {
        // TODO: choose ROLLING, BLUE_GREEN or CANARY
        return "ROLLING";
    }
}
