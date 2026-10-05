public class Main {
    public static int warmupInvocations(int targetMillis, int observedMillis, int step) {
        if (observedMillis >= targetMillis) {
            return 0;
        }
        long effectiveStep = step <= 0 ? 1 : step;
        long missing = (long) targetMillis - observedMillis;
        long invocations = (missing + effectiveStep - 1) / effectiveStep;
        return (int) Math.min(invocations, 1_000_000L);
    }
}
