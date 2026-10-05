import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null or blank input reports nothing", () ->
                Main.seams(null).isEmpty() && Main.seams(List.of("", "   ")).isEmpty());
        t.put("plain code has no seam", () -> Main.seams(
                List.of("int total = 0;", "return calculate(total);")).isEmpty());
        t.put("a static call is reported with its line number", () -> Main.seams(
                List.of("int total = 0;", "double rate = Math.random();"))
                .equals(List.of("2: static call Math.random")));
        t.put("a direct constructor is reported", () -> Main.seams(
                List.of("var clock = new SystemClock();"))
                .equals(List.of("1: direct constructor SystemClock")));
        t.put("a clock read is reported", () -> Main.seams(
                List.of("long now = Clock.systemUTC().millis();", "long stamp = System.currentTimeMillis();"))
                .equals(List.of("1: clock read", "2: clock read")));
        t.put("several seams on one line are each reported", () -> Main.seams(
                List.of("var service = new PaymentClient(Math.random());"))
                .equals(List.of("1: direct constructor PaymentClient", "1: static call Math.random")));
        t.put("a null line is skipped", () -> {
            List<String> lines = new ArrayList<>();
            lines.add(null);
            lines.add("new Clock();");
            return Main.seams(lines).equals(List.of("2: direct constructor Clock"));
        });
        t.put("system out is not a seam", () ->
                Main.seams(List.of("System.out.println(\"done\");")).isEmpty()
                        && Main.seams(List.of("String name = \"Math.max\";")).isEmpty());
        return t;
    }
}
