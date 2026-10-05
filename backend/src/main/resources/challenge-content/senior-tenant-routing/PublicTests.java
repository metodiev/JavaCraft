import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("standard tenants share the pooled datasource", () ->
                Main.datasourceFor("acme", Map.of("acme", "STANDARD")).equals("pooled"));
        t.put("regulated tenants get an isolated datasource", () ->
                Main.datasourceFor("bankco", Map.of("bankco", "REGULATED")).equals("isolated:bankco"));
        t.put("unknown tiers fall back to the pooled datasource", () ->
                Main.datasourceFor("acme", Map.of("acme", "PLATINUM")).equals("pooled"));
        t.put("a missing tier entry falls back to the pooled datasource", () ->
                Main.datasourceFor("acme", Map.of()).equals("pooled")
                        && Main.datasourceFor("acme", null).equals("pooled"));
        t.put("tier names ignore case and whitespace", () ->
                Main.datasourceFor("bankco", Map.of("bankco", "  regulated ")).equals("isolated:bankco"));
        t.put("isolated datasources are tenant specific", () ->
                !Main.datasourceFor("bankco", Map.of("bankco", "REGULATED"))
                        .equals(Main.datasourceFor("insureco", Map.of("insureco", "REGULATED"))));
        t.put("a null or blank tenant id is rejected", () -> {
            try { Main.datasourceFor(null, Map.of()); return false; }
            catch (IllegalArgumentException e) { }
            try { Main.datasourceFor("  ", Map.of()); return false; }
            catch (IllegalArgumentException e) { return true; }
        });
        return t;
    }
}
