public class Main {
    public enum State { CLOSED, OPEN, HALF_OPEN }

    public static boolean mayCall(State state, int probesInFlight, int maxProbes) {
        // TODO: decide whether a call is allowed
        return true;
    }

    public static State afterCall(State state, boolean success, int consecutiveFailures, int threshold) {
        // TODO: compute the next state
        return state;
    }
}
