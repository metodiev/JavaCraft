public class Main {
    public static String route(long lagMillis, long maxLagMillis, boolean readYourWrites) {
        if (lagMillis < 0 || maxLagMillis < 0) {
            throw new IllegalArgumentException("lag must not be negative");
        }
        if (readYourWrites || maxLagMillis == 0) {
            return "PRIMARY";
        }
        return lagMillis <= maxLagMillis ? "REPLICA" : "PRIMARY";
    }
}
