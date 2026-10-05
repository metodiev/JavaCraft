public class Main {
    public static String nextState(String state, boolean callSucceeded, int failureRate, int threshold) {
        if (state == null) {
            throw new IllegalArgumentException("state is required");
        }
        if (!state.equals("CLOSED") && !state.equals("OPEN") && !state.equals("HALF_OPEN")) {
            throw new IllegalArgumentException("unknown state: " + state);
        }
        if (failureRate < 0 || failureRate > 100) {
            throw new IllegalArgumentException("failureRate must be 0..100");
        }
        if (threshold < 1 || threshold > 100) {
            throw new IllegalArgumentException("threshold must be 1..100");
        }
        switch (state) {
            case "OPEN":
                return "OPEN";
            case "HALF_OPEN":
                return callSucceeded ? "CLOSED" : "OPEN";
            default:
                return !callSucceeded && failureRate >= threshold ? "OPEN" : "CLOSED";
        }
    }
}
