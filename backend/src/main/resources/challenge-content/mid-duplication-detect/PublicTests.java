import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("null or empty input has no duplication", () ->
                Main.duplicatedBlocks(null, 2).isEmpty() && Main.duplicatedBlocks(List.of(), 2).isEmpty());
        t.put("unique lines have no duplication", () -> Main.duplicatedBlocks(
                List.of("int a = 1;", "int b = 2;", "int c = 3;"), 2).isEmpty());
        t.put("a repeated two line block is reported", () -> Main.duplicatedBlocks(
                List.of("int a = 1;", "int b = 2;", "int c = 3;", "int a = 1;", "int b = 2;"), 2)
                .equals(List.of("1-2")));
        t.put("normalisation ignores case and surrounding space", () -> Main.duplicatedBlocks(
                List.of("  int A = 1;", "int b = 2;", "int a = 1;", "  INT B = 2;"), 2)
                .equals(List.of("1-2")));
        t.put("a block shorter than the minimum is ignored", () -> Main.duplicatedBlocks(
                List.of("int a = 1;", "int b = 2;", "int a = 1;", "int b = 2;"), 3).isEmpty());
        t.put("a three line block matches at the minimum size", () -> Main.duplicatedBlocks(
                List.of("x();", "y();", "z();", "x();", "y();", "z();"), 3).equals(List.of("1-3")));
        t.put("overlapping repeated windows merge into one region", () -> Main.duplicatedBlocks(
                List.of("a();", "b();", "a();", "b();", "a();", "b();"), 2).equals(List.of("1-4")));
        t.put("blank lines are ignored when comparing blocks", () -> Main.duplicatedBlocks(
                List.of("int a = 1;", "", "int b = 2;", "int a = 1;", "int b = 2;"), 2)
                .equals(List.of("1-3")));
        t.put("separate duplicated regions are reported in order", () -> Main.duplicatedBlocks(
                List.of("a();", "b();", "x();", "c();", "d();", "a();", "b();", "y();", "c();", "d();"), 2)
                .equals(List.of("1-2", "4-5")));
        return t;
    }
}
