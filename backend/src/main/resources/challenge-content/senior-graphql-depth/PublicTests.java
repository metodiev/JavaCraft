import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("counts nested selection sets", () -> Main.depth("query { user { name friends { id } } }") == 3);
        t.put("sibling sets do not add depth", () -> Main.depth("{ a { x } b { y } }") == 2);
        t.put("braces inside a string are ignored", () -> Main.depth(
                "query { user(filter: \"{ not a brace }\") { id } }") == 2);
        t.put("triple quoted blocks are ignored", () -> Main.depth(
                "query { a(text: \"\"\"{ { { }\"\"\") { b } }") == 2);
        t.put("comments are ignored", () -> Main.depth("query { a # ignore { and } here\n { b } }") == 2);
        t.put("escaped quotes do not end a string", () -> Main.depth(
                "query { a(note: \"say \\\"{\\\"\") { b } }") == 2);
        t.put("unbalanced braces are malformed", () -> Main.depth("{ a { b }") == -1 && Main.depth("} {") == -1
                && Main.depth("{ a } b {") == -1);
        t.put("a query without braces has depth zero", () -> Main.depth("query UserName") == 0
                && Main.depth("fragment F on User { id }") == 1);
        t.put("null blank or unterminated input is malformed", () -> Main.depth(null) == -1 && Main.depth("   ") == -1
                && Main.depth("") == -1 && Main.depth("{ a(note: \"unterminated) }") == -1);
        return t;
    }
}
