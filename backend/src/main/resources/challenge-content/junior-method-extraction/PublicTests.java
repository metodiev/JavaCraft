import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a long method with two responsibilities is extracted", () ->
                Main.shouldExtract(40, 2, 3));
        t.put("exactly twenty lines with one responsibility stays", () ->
                !Main.shouldExtract(20, 1, 1));
        t.put("twenty one lines with one responsibility is extracted", () ->
                Main.shouldExtract(21, 1, 1));
        t.put("two responsibilities trigger extraction even when short", () ->
                Main.shouldExtract(10, 2, 1) && Main.shouldExtract(7, 3, 1));
        t.put("eight or more used variables trigger extraction", () ->
                Main.shouldExtract(10, 1, 8) && Main.shouldExtract(10, 1, 20));
        t.put("seven used variables is still acceptable", () ->
                !Main.shouldExtract(10, 1, 7));
        t.put("a six line method is never extracted", () ->
                !Main.shouldExtract(6, 5, 30) && !Main.shouldExtract(0, 0, 0) && !Main.shouldExtract(5, 3, 1));
        t.put("a short method with no responsibility signal stays", () ->
                !Main.shouldExtract(10, 1, 3) && !Main.shouldExtract(15, 0, 2));
        return t;
    }
}
