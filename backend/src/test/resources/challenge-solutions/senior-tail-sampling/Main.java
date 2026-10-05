public class Main {
    public static int sampleCount(int traces, int errors, double errorSampleRate, double baselineRate) {
        if (traces < 0 || errors < 0 || errors > traces) {
            throw new IllegalArgumentException("errors must be within 0..traces");
        }
        if (!validRate(errorSampleRate) || !validRate(baselineRate)) {
            throw new IllegalArgumentException("sample rates must be finite and within 0..1");
        }
        int baseline = traces - errors;
        long kept = (long) Math.ceil(errors * errorSampleRate) + (long) Math.ceil(baseline * baselineRate);
        return (int) Math.min(traces, kept);
    }

    private static boolean validRate(double rate) {
        return Double.isFinite(rate) && rate >= 0 && rate <= 1;
    }
}
