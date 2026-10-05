public class Main {
    public static double instability(int afferent, int efferent) {
        if (afferent < 0 || efferent < 0) {
            throw new IllegalArgumentException("coupling counts must not be negative");
        }
        double total = (double) afferent + efferent;
        if (total == 0.0) {
            return 0.0;
        }
        return efferent / total;
    }
}
