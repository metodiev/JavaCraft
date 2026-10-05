import java.math.BigDecimal;

public class Main {
    public static String render(BigDecimal value) {
        return value == null ? "" : value.toPlainString();
    }
}
