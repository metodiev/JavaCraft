import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a read only step needs no transaction", () ->
                Main.transactionalOperations(List.of("load order")).isEmpty());
        t.put("a write only step is not a read modify write unit", () ->
                Main.transactionalOperations(List.of("insert payment")).isEmpty());
        t.put("a step that both reads and writes is transactional", () ->
                Main.transactionalOperations(List.of("load and update stock")).equals(List.of("load and update stock")));
        t.put("a step that neither reads nor writes is left alone", () ->
                Main.transactionalOperations(List.of("send receipt email")).isEmpty());
        t.put("only the transactional steps are returned, in order", () ->
                Main.transactionalOperations(List.of("load order", "insert payment", "send email", "load and update stock"))
                        .equals(List.of("load and update stock")));
        t.put("an empty step list returns an empty result", () -> Main.transactionalOperations(List.of()).isEmpty());
        t.put("a null step list returns an empty result", () -> Main.transactionalOperations(null).isEmpty());
        t.put("blank and null steps are ignored", () ->
                Main.transactionalOperations(Arrays.asList("  ", null, "select then delete rows")).equals(List.of("select then delete rows")));
        t.put("keywords are matched without regard to case or extra spaces", () ->
                Main.transactionalOperations(List.of("  UPDATE after SELECT  ")).equals(List.of("  UPDATE after SELECT  ")));
        return t;
    }
}
