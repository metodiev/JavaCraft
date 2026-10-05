import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a runtime with build tools gets a multi-stage build", () -> {
            List<String> out = Main.measures(true, false, "eclipse-temurin:21-jdk");
            return out.contains("use a multi-stage build") && out.contains("use a JRE base image");
        });
        t.put("a slim base image is already acceptable", () -> {
            List<String> out = Main.measures(false, true, "eclipse-temurin:21-jre-alpine");
            return !out.contains("use a JRE base image") && !out.contains("use a multi-stage build");
        });
        t.put("a jdk base image is flagged", () -> {
            List<String> out = Main.measures(false, true, "eclipse-temurin:21-jdk");
            return out.contains("use a JRE base image");
        });
        t.put("a fat base image is flagged", () -> {
            List<String> out = Main.measures(false, true, "openjdk:21");
            return out.contains("use a slim base image");
        });
        t.put("build tools in a multi-stage runtime are still flagged", () -> {
            List<String> out = Main.measures(true, true, "eclipse-temurin:21-jre-alpine");
            return out.contains("remove build tools from the runtime image")
                    && !out.contains("use a multi-stage build");
        });
        t.put("output order is stable and deduplicated", () -> {
            List<String> out = Main.measures(true, false, "openjdk:21");
            Set<String> unique = new LinkedHashSet<>(out);
            return out.size() == unique.size() && out.indexOf("use a multi-stage build")
                    < out.indexOf("use a JRE base image");
        });
        t.put("a null base image only reports the boolean findings", () -> {
            List<String> out = Main.measures(true, false, null);
            return out.equals(List.of("use a multi-stage build"))
                    && Main.measures(false, false, null).isEmpty();
        });
        t.put("a clean image reports nothing", () -> {
            List<String> out = Main.measures(false, true, "eclipse-temurin:21-jre-alpine");
            return out.isEmpty();
        });
        return t;
    }
}
