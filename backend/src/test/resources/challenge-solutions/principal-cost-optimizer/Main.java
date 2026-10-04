public class Main {
    public static double costPerSuccess(double totalCost, long successes) {
        if (!Double.isFinite(totalCost) || totalCost < 0 || successes < 0) {
            throw new IllegalArgumentException("invalid cost inputs");
        }
        return successes == 0 ? Double.POSITIVE_INFINITY : totalCost / successes;
    }

    public static String cheaperOption(double costA, long successesA, double costB, long successesB) {
        double a = costPerSuccess(costA, successesA);
        double b = costPerSuccess(costB, successesB);
        if (a == b) {
            return "TIE";
        }
        return a < b ? "A" : "B";
    }
}
