public class Main {
    private static final int[] STEPS = {1, 5, 25, 50, 100};

    public static boolean mayCutOver(boolean dataInSync, boolean rollbackReady, boolean healthChecksPassing) {
        return dataInSync && rollbackReady && healthChecksPassing;
    }

    public static int nextTrafficPercent(int currentPercent, boolean healthy) {
        if (currentPercent < 0 || currentPercent > 100) {
            throw new IllegalArgumentException("percent must be between 0 and 100");
        }
        if (!healthy) {
            return 0;
        }
        for (int step : STEPS) {
            if (step > currentPercent) {
                return step;
            }
        }
        return 100;
    }
}
