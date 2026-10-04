public class Main {
    public enum State { CLOSED, OPEN, HALF_OPEN }

    public static boolean mayCall(State state, int probesInFlight, int maxProbes) {
        if (state == null) {
            return false;
        }
        return switch (state) {
            case CLOSED -> true;
            case OPEN -> false;
            case HALF_OPEN -> probesInFlight < maxProbes;
        };
    }

    public static State afterCall(State state, boolean success, int consecutiveFailures, int threshold) {
        if (state == null) {
            return State.OPEN;
        }
        return switch (state) {
            case HALF_OPEN -> success ? State.CLOSED : State.OPEN;
            case CLOSED -> !success && consecutiveFailures >= threshold ? State.OPEN : State.CLOSED;
            case OPEN -> State.OPEN;
        };
    }
}
