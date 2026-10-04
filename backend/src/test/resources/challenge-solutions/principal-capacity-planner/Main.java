public class Main {
    public static int requiredWorkers(double requestsPerSecond, double secondsPerRequest, double targetUtilization) {
        if (!Double.isFinite(requestsPerSecond) || !Double.isFinite(secondsPerRequest)
                || requestsPerSecond < 0 || secondsPerRequest < 0
                || !(targetUtilization > 0 && targetUtilization < 1)) {
            throw new IllegalArgumentException("invalid capacity inputs");
        }
        double workers = Math.ceil(requestsPerSecond * secondsPerRequest / targetUtilization);
        if (!Double.isFinite(workers) || workers > Integer.MAX_VALUE) {
            throw new IllegalArgumentException("capacity exceeds supported range");
        }
        return (int) workers;
    }
}
