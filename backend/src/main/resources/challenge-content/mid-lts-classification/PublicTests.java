import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("8 and 11 are lts", () -> Main.isLts(8) && Main.isLts(11));
        t.put("17 21 25 and 29 are lts", () -> Main.isLts(17) && Main.isLts(21)
                && Main.isLts(25) && Main.isLts(29));
        t.put("9 10 and 12 are not lts", () -> !Main.isLts(9) && !Main.isLts(10) && !Main.isLts(12));
        t.put("18 22 and 23 are not lts", () -> !Main.isLts(18) && !Main.isLts(22) && !Main.isLts(23));
        t.put("odd versions off the cadence are not lts", () -> !Main.isLts(19) && !Main.isLts(27)
                && !Main.isLts(15));
        t.put("the release after 25 is 29", () -> Main.isLts(29) && !Main.isLts(28) && !Main.isLts(30));
        t.put("the cadence continues past 29", () -> Main.isLts(33) && Main.isLts(37)
                && !Main.isLts(31) && !Main.isLts(35));
        t.put("non-positive versions are not lts", () -> !Main.isLts(0) && !Main.isLts(-17)
                && !Main.isLts(1));
        return t;
    }
}
