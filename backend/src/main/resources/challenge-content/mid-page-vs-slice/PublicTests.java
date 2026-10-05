import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("needing the total count chooses page",
                () -> Main.chooseReturnType(true, false, false).equals("Page"));
        t.put("the total count outranks a large table and infinite scroll",
                () -> Main.chooseReturnType(true, true, false).equals("Page")
                        && Main.chooseReturnType(true, true, true).equals("Page")
                        && Main.chooseReturnType(true, false, true).equals("Page"));
        t.put("infinite scroll without a count chooses slice",
                () -> Main.chooseReturnType(false, false, true).equals("Slice"));
        t.put("a large table without a count chooses slice",
                () -> Main.chooseReturnType(false, true, false).equals("Slice"));
        t.put("a large table with infinite scroll still chooses slice",
                () -> Main.chooseReturnType(false, true, true).equals("Slice"));
        t.put("a small table with no count requirement keeps the default page",
                () -> Main.chooseReturnType(false, false, false).equals("Page"));
        return t;
    }
}
