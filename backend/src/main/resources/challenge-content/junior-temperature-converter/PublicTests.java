import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("freezing point converts to 32", () -> close(Main.celsiusToFahrenheit(0), 32));
        t.put("boiling point converts to 212", () -> close(Main.celsiusToFahrenheit(100), 212));
        t.put("negative values convert correctly", () -> close(Main.celsiusToFahrenheit(-40), -40));
        t.put("fractions are preserved", () -> close(Main.celsiusToFahrenheit(36.6), 97.88));
        t.put("NaN is rejected", () -> rejects(Double.NaN));
        t.put("infinity is rejected", () -> rejects(Double.POSITIVE_INFINITY));
        return t;
    }

    private static boolean close(double actual, double expected) {
        return Math.abs(actual - expected) < 1e-9;
    }

    private static boolean rejects(double value) {
        try {
            Main.celsiusToFahrenheit(value);
            return false;
        } catch (IllegalArgumentException expected) {
            return true;
        }
    }
}
