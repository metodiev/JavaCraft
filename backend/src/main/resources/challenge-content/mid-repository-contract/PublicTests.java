import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a lookup only contract has one method", () ->
                Main.contractMethods(true, false, false).equals(List.of("findById")));
        t.put("a save only contract has one method", () ->
                Main.contractMethods(false, true, false).equals(List.of("save")));
        t.put("an owner query only contract has one method", () ->
                Main.contractMethods(false, false, true).equals(List.of("findByOwner")));
        t.put("all needs are listed in a stable order", () ->
                Main.contractMethods(true, true, true).equals(List.of("findById", "save", "findByOwner")));
        t.put("lookup and save combine in order", () ->
                Main.contractMethods(true, true, false).equals(List.of("findById", "save")));
        t.put("save and owner query combine in order", () ->
                Main.contractMethods(false, true, true).equals(List.of("save", "findByOwner")));
        t.put("no needs give an empty contract", () -> Main.contractMethods(false, false, false).isEmpty());
        t.put("the contract uses only the agreed domain methods", () ->
                Main.contractMethods(true, true, true).stream()
                        .allMatch(name -> List.of("findById", "save", "findByOwner").contains(name)));
        return t;
    }
}
