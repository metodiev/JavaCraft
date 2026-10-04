public class Main {
    public static double celsiusToFahrenheit(double celsius) {
        if (!Double.isFinite(celsius)) {
            throw new IllegalArgumentException("celsius must be finite");
        }
        return celsius * 9 / 5 + 32;
    }
}
