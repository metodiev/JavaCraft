public class Main {
    public static String route(long lagMillis, long maxLagMillis, boolean readYourWrites) {
        // TODO: fall back to the primary when the replica is too far behind
        return "REPLICA";
    }
}
