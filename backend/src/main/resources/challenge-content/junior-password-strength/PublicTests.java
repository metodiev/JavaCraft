import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null password is weak", () -> Main.strength(null).equals("WEAK"));
        t.put("short password is weak", () -> Main.strength("Ab1!").equals("WEAK"));
        t.put("eight characters with one class is fair", () -> Main.strength("abcdefgh").equals("FAIR"));
        t.put("nine characters with two classes is still fair", () -> Main.strength("abcdefg12").equals("FAIR"));
        t.put("ten characters with two classes is good", () -> Main.strength("abcde12345").equals("GOOD"));
        t.put("eleven characters with four classes is good", () -> Main.strength("abcdefg1!A").equals("GOOD"));
        t.put("twelve characters with three classes is strong", () -> Main.strength("abcdef12345!").equals("STRONG"));
        t.put("long single class password stays fair", () -> Main.strength("aaaaaaaaaaaaaaaaaaaa").equals("FAIR"));
        return t;
    }
}
