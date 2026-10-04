public class Main {
    public static double remainingBudget(double targetAvailability, double observedFailureRatio) {
        if (!(targetAvailability > 0 && targetAvailability < 1)
                || !(observedFailureRatio >= 0 && observedFailureRatio <= 1)) {
            throw new IllegalArgumentException("invalid SLO arguments");
        }
        double allowed = 1 - targetAvailability;
        return Math.max(0, 1 - observedFailureRatio / allowed);
    }
}
