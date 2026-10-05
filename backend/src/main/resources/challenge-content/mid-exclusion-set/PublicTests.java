import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("inherited exclusions are added when inheritance is enabled", () -> Main.excluded(
                Set.of("org.slf4j:slf4j-api"), Set.of("commons-logging:commons-logging"), true)
                .equals(Set.of("org.slf4j:slf4j-api", "commons-logging:commons-logging")));
        t.put("inherited exclusions are ignored when inheritance is disabled", () -> Main.excluded(
                Set.of("org.slf4j:slf4j-api"), Set.of("commons-logging:commons-logging"), false)
                .equals(Set.of("org.slf4j:slf4j-api")));
        t.put("inherited exclusions survive an empty declared set", () -> Main.excluded(
                Set.of(), Set.of("a:b"), true).equals(Set.of("a:b")));
        t.put("null arguments count as empty sets", () ->
                Main.excluded(null, null, true).isEmpty() && Main.excluded(null, Set.of("a:b"), false).isEmpty());
        t.put("null entries are ignored", () -> {
            Set<String> declared = new HashSet<>();
            declared.add(null);
            declared.add("a:b");
            return Main.excluded(declared, null, true).equals(Set.of("a:b"));
        });
        t.put("wildcards are kept as literal strings", () -> Main.excluded(
                Set.of("org.example:*"), Set.of(), true).equals(Set.of("org.example:*")));
        t.put("the result is sorted", () -> new ArrayList<>(Main.excluded(
                Set.of("z:z", "a:a"), Set.of("m:m"), true)).equals(List.of("a:a", "m:m", "z:z")));
        return t;
    }
}
