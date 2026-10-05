import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("currency is normalised to upper case", () ->
                new Main.Money(100, "usd").currency().equals("USD"));
        t.put("equal values match regardless of currency case", () ->
                new Main.Money(100, "usd").equals(new Main.Money(100, "USD"))
                        && new Main.Money(100, "usd").hashCode() == new Main.Money(100, "USD").hashCode());
        t.put("different amounts are not equal", () ->
                !new Main.Money(100, "USD").equals(new Main.Money(101, "USD")));
        t.put("different currencies are not equal", () ->
                !new Main.Money(100, "USD").equals(new Main.Money(100, "EUR")));
        t.put("sameValue matches equal values", () ->
                new Main.Money(250, "eur").sameValue(new Main.Money(250, "EUR")));
        t.put("sameValue rejects different values", () ->
                !new Main.Money(250, "EUR").sameValue(new Main.Money(250, "USD")));
        t.put("sameValue treats null as unequal", () ->
                !new Main.Money(250, "EUR").sameValue(null));
        t.put("a null currency becomes empty", () ->
                new Main.Money(5, null).currency().isEmpty()
                        && new Main.Money(5, null).equals(new Main.Money(5, "")));
        t.put("negative amounts compare by value", () ->
                new Main.Money(-5, "usd").sameValue(new Main.Money(-5, "USD"))
                        && !new Main.Money(-5, "USD").sameValue(new Main.Money(5, "USD")));
        return t;
    }
}
