import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    private static Map<String, Map<String, String>> directory() {
        Map<String, String> users = new LinkedHashMap<>();
        users.put("alice", "Berlin");
        users.put("bob", "Paris");
        Map<String, Map<String, String>> directory = new LinkedHashMap<>();
        directory.put("acme", users);
        return directory;
    }

    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("finds the city of a known user", () ->
                Main.cityOf(directory(), "acme", "alice").equals(Optional.of("Berlin")));
        t.put("unknown user gives empty", () -> Main.cityOf(directory(), "acme", "carol").isEmpty());
        t.put("unknown tenant gives empty", () -> Main.cityOf(directory(), "globex", "alice").isEmpty());
        t.put("null directory gives empty", () -> Main.cityOf(null, "acme", "alice").isEmpty());
        t.put("null tenant gives empty", () -> Main.cityOf(directory(), null, "alice").isEmpty());
        t.put("null user gives empty", () -> Main.cityOf(directory(), "acme", null).isEmpty());
        t.put("null inner map gives empty", () -> {
            Map<String, Map<String, String>> directory = new LinkedHashMap<>();
            directory.put("acme", null);
            return Main.cityOf(directory, "acme", "alice").isEmpty();
        });
        t.put("null city value gives empty", () -> {
            Map<String, String> users = new LinkedHashMap<>();
            users.put("alice", null);
            Map<String, Map<String, String>> directory = new LinkedHashMap<>();
            directory.put("acme", users);
            return Main.cityOf(directory, "acme", "alice").isEmpty();
        });
        t.put("blank city value gives empty", () -> {
            Map<String, String> users = new LinkedHashMap<>();
            users.put("alice", "  ");
            Map<String, Map<String, String>> directory = new LinkedHashMap<>();
            directory.put("acme", users);
            return Main.cityOf(directory, "acme", "alice").isEmpty();
        });
        return t;
    }
}
