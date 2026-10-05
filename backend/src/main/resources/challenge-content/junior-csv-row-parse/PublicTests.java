import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("plain fields are split on commas", () ->
                Main.fields("a,b,c").equals(List.of("a", "b", "c")));
        t.put("quoted fields keep their commas", () ->
                Main.fields("\"a,b\",c").equals(List.of("a,b", "c")));
        t.put("escaped double quotes decode to one quote", () ->
                Main.fields("\"say \"\"hi\"\"\",x").equals(List.of("say \"hi\"", "x")));
        t.put("empty fields are preserved", () ->
                Main.fields(",").equals(List.of("", ""))
                        && Main.fields("a,,b,").equals(List.of("a", "", "b", ""))
                        && Main.fields("").equals(List.of("")));
        t.put("a quoted empty field is an empty string", () ->
                Main.fields("\"\",x").equals(List.of("", "x")));
        t.put("fields are not trimmed", () ->
                Main.fields("a, b ").equals(List.of("a", " b ")));
        t.put("a quote inside an unquoted field is literal", () ->
                Main.fields("ab\"cd,e").equals(List.of("ab\"cd", "e")));
        t.put("malformed quoting is rejected", () -> {
            try { Main.fields("\"abc"); return false; } catch (IllegalArgumentException e) { }
            try { Main.fields("\"a\"b,c"); return false; } catch (IllegalArgumentException e) { }
            return true;
        });
        t.put("a null row is rejected", () -> {
            try { Main.fields(null); return false; } catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
