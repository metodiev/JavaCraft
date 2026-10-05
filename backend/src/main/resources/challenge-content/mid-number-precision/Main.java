import java.math.BigDecimal;

public class Main {
    public static String render(BigDecimal value) {
        // TODO: render the decimal without an exponent and without losing its scale
        return value == null ? "" : value.toString();
    }
}
