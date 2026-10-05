import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the declared scale is preserved", () ->
                Main.render(new BigDecimal("0.10")).equals("0.10"));
        t.put("a positive exponent is expanded", () ->
                Main.render(new BigDecimal("1E+2")).equals("100"));
        t.put("a negative exponent is expanded", () ->
                Main.render(new BigDecimal("1E-3")).equals("0.001"));
        t.put("trailing zeros and sign survive", () ->
                Main.render(new BigDecimal("-2.500")).equals("-2.500"));
        t.put("large unscaled values stay exact", () ->
                Main.render(new BigDecimal("123456789012345678901234567890.00"))
                        .equals("123456789012345678901234567890.00"));
        t.put("zero keeps its scale", () -> Main.render(new BigDecimal("0.000")).equals("0.000"));
        t.put("no output uses an exponent", () ->
                !Main.render(new BigDecimal("1E+10")).contains("E")
                        && Main.render(new BigDecimal("1E+10")).equals("10000000000"));
        t.put("null renders as an empty string", () -> Main.render(null).isEmpty());
        return t;
    }
}
