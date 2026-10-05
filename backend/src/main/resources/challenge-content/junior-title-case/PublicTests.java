import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("capitalises a simple sentence", () -> Main.toTitleCase("hello world").equals("Hello World"));
        t.put("collapses repeated spaces and trims", () -> Main.toTitleCase("  java   craft  ").equals("Java Craft"));
        t.put("lowercases the rest of each word", () -> Main.toTitleCase("JAVA CRASH course").equals("Java Crash Course"));
        t.put("keeps digits attached to their word", () -> Main.toTitleCase("the 3rd item!").equals("The 3rd Item!"));
        t.put("handles a single word", () -> Main.toTitleCase("oNE").equals("One"));
        t.put("returns empty for null", () -> Main.toTitleCase(null).isEmpty());
        t.put("returns empty for blank", () -> Main.toTitleCase("   ").isEmpty());
        return t;
    }
}
