import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("builds a config with host and port", () -> {
            Main.ServerConfig config = Main.ServerConfig.builder().host("db.local").port(5432).build();
            return config.host().equals("db.local") && config.port() == 5432;
        });
        t.put("collects tags in insertion order", () -> {
            Main.ServerConfig config = Main.ServerConfig.builder().host("h").port(8080)
                    .tag("primary").tag("eu-west").build();
            return config.tags().equals(List.of("primary", "eu-west"));
        });
        t.put("tags default to an empty list", () ->
                Main.ServerConfig.builder().host("h").port(80).build().tags().isEmpty());
        t.put("tags are a defensive copy that ignores later builder changes", () -> {
            Main.ServerConfig.Builder builder = Main.ServerConfig.builder().host("h").port(80).tag("a");
            Main.ServerConfig config = builder.build();
            builder.tag("b");
            return config.tags().equals(List.of("a"));
        });
        t.put("returned tags cannot be modified", () -> {
            List<String> tags = Main.ServerConfig.builder().host("h").port(80).tag("a").build().tags();
            try {
                tags.add("b");
                return false;
            } catch (UnsupportedOperationException e) {
                return true;
            }
        });
        t.put("missing host is rejected at build time", () -> {
            try {
                Main.ServerConfig.builder().port(80).build();
                return false;
            } catch (IllegalStateException e) {
                return true;
            }
        });
        t.put("port zero is rejected", () -> {
            try {
                Main.ServerConfig.builder().host("h").port(0).build();
                return false;
            } catch (IllegalStateException e) {
                return true;
            }
        });
        t.put("negative port is rejected", () -> {
            try {
                Main.ServerConfig.builder().host("h").port(-1).build();
                return false;
            } catch (IllegalStateException e) {
                return true;
            }
        });
        return t;
    }
}
