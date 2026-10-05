public class Main {
    public static String strategy(double requestsPerSecond, boolean errorsMatter) {
        if (!Double.isFinite(requestsPerSecond) || requestsPerSecond < 0) {
            throw new IllegalArgumentException("requestsPerSecond must be finite and not negative");
        }
        if (requestsPerSecond <= 10) {
            return "ALWAYS_ON";
        }
        return errorsMatter ? "TAIL_BASED" : "PROBABILISTIC";
    }
}
