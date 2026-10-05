import java.util.Locale;

public class Main {
    public static String verdict(double baselineP99, double candidateP99, double tolerance) {
        if (!Double.isFinite(baselineP99) || baselineP99 <= 0) {
            throw new IllegalArgumentException("baselineP99 must be positive and finite");
        }
        if (!Double.isFinite(candidateP99) || candidateP99 < 0) {
            throw new IllegalArgumentException("candidateP99 must be finite and not negative");
        }
        if (!Double.isFinite(tolerance) || tolerance < 0) {
            throw new IllegalArgumentException("tolerance must be finite and not negative");
        }
        double change = (candidateP99 - baselineP99) / baselineP99;
        String verdict = change <= tolerance ? "PASS" : change <= 2 * tolerance ? "WARN" : "FAIL";
        return verdict + " " + String.format(Locale.ROOT, "%+.1f%%", change * 100);
    }
}
