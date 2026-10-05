public class Main {
    public static String model(double arrivalRate, boolean constantTraffic, int maxConcurrency) {
        if (maxConcurrency >= 2) {
            return "CLOSED";
        }
        boolean usableRate = arrivalRate > 0 && arrivalRate < 100;
        if (!usableRate) {
            return "CLOSED";
        }
        if (maxConcurrency == 0 && constantTraffic) {
            return "OPEN";
        }
        if (maxConcurrency == 1) {
            return "OPEN";
        }
        return "CLOSED";
    }
}
