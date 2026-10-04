public class Main {
    public static boolean mayPromote(long replicationLagMillis, long maxLagMillis, boolean oldPrimaryFenced) {
        if (replicationLagMillis < 0 || maxLagMillis < 0) {
            return false;
        }
        return oldPrimaryFenced && replicationLagMillis <= maxLagMillis;
    }
}
