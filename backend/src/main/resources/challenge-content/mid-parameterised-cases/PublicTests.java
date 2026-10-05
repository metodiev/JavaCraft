import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static Object[] row(int index) {
        return Main.cases(List.of("alpha", "beta")).get(index);
    }

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("one row per input is produced", () ->
                Main.cases(List.of("alpha", "beta", "gamma")).size() == 3);
        t.put("basic rows report name input and expected", () -> {
            Object[] first = Main.cases(List.of("alpha")).get(0);
            Object[] second = Main.cases(List.of("beta")).get(0);
            return first.length == 3
                    && "alpha".equals(first[0]) && "alpha".equals(first[1]) && Integer.valueOf(5).equals(first[2])
                    && "beta".equals(second[0]) && "beta".equals(second[1]) && Integer.valueOf(4).equals(second[2]);
        });
        t.put("empty input gets its own row", () -> {
            Object[] row = Main.cases(List.of("")).get(0);
            return "empty".equals(row[0]) && "".equals(row[1]) && Integer.valueOf(0).equals(row[2]);
        });
        t.put("blank input is trimmed before measuring", () -> {
            Object[] row = Main.cases(List.of("   ")).get(0);
            return "blank".equals(row[0]) && "   ".equals(row[1]) && Integer.valueOf(0).equals(row[2]);
        });
        t.put("rows keep the order of the inputs", () -> {
            List<Object[]> rows = Main.cases(List.of("zz", "a", "mmm"));
            return "zz".equals(rows.get(0)[0]) && "a".equals(rows.get(1)[0]) && "mmm".equals(rows.get(2)[0]);
        });
        t.put("null or empty input returns an empty list", () ->
                Main.cases(null).isEmpty() && Main.cases(List.of()).isEmpty());
        t.put("the name is the trimmed input", () ->
                "alpha".equals(row(0)[0]) && "beta".equals(row(1)[0]));
        return t;
    }
}
