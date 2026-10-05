import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a minimal service needs the core web and observability stack", () ->
                Main.baselineComponents(false, false, false).equals(List.of(
                        "spring-boot-starter-web",
                        "spring-boot-starter-actuator",
                        "structured logging with a correlation id")));
        t.put("an api service adds validation and problem details", () ->
                Main.baselineComponents(true, false, false).equals(List.of(
                        "spring-boot-starter-web",
                        "spring-boot-starter-actuator",
                        "structured logging with a correlation id",
                        "spring-boot-starter-validation",
                        "RFC 9457 problem details error contract")));
        t.put("a data service adds persistence and migrations", () ->
                Main.baselineComponents(false, true, false).equals(List.of(
                        "spring-boot-starter-web",
                        "spring-boot-starter-actuator",
                        "structured logging with a correlation id",
                        "spring-boot-starter-data-jpa",
                        "database migrations managed by flyway or liquibase")));
        t.put("a production service adds security metrics and health probes", () ->
                Main.baselineComponents(false, false, true).equals(List.of(
                        "spring-boot-starter-web",
                        "spring-boot-starter-actuator",
                        "structured logging with a correlation id",
                        "spring-boot-starter-security",
                        "micrometer metrics with alert thresholds",
                        "liveness and readiness health probes")));
        t.put("everything together keeps the documented order", () ->
                Main.baselineComponents(true, true, true).equals(List.of(
                        "spring-boot-starter-web",
                        "spring-boot-starter-actuator",
                        "structured logging with a correlation id",
                        "spring-boot-starter-validation",
                        "RFC 9457 problem details error contract",
                        "spring-boot-starter-data-jpa",
                        "database migrations managed by flyway or liquibase",
                        "spring-boot-starter-security",
                        "micrometer metrics with alert thresholds",
                        "liveness and readiness health probes")));
        t.put("the core components are always present", () -> {
            for (boolean a : new boolean[] {false, true}) {
                for (boolean b : new boolean[] {false, true}) {
                    for (boolean c : new boolean[] {false, true}) {
                        List<String> components = Main.baselineComponents(a, b, c);
                        if (!components.containsAll(List.of("spring-boot-starter-web", "spring-boot-starter-actuator",
                                "structured logging with a correlation id"))) {
                            return false;
                        }
                    }
                }
            }
            return true;
        });
        t.put("validation and persistence are independent of each other", () -> {
            List<String> apiOnly = Main.baselineComponents(true, false, false);
            List<String> dataOnly = Main.baselineComponents(false, true, false);
            return apiOnly.contains("spring-boot-starter-validation")
                    && !apiOnly.contains("spring-boot-starter-data-jpa")
                    && dataOnly.contains("spring-boot-starter-data-jpa")
                    && !dataOnly.contains("spring-boot-starter-validation");
        });
        t.put("production concerns are only added for production services", () -> {
            List<String> development = Main.baselineComponents(true, true, false);
            List<String> production = Main.baselineComponents(true, true, true);
            return !development.contains("spring-boot-starter-security")
                    && production.contains("spring-boot-starter-security")
                    && production.containsAll(development);
        });
        t.put("the result is never null and has no duplicates", () -> {
            List<String> components = Main.baselineComponents(true, true, true);
            return components.size() == 10 && new HashSet<>(components).size() == 10;
        });
        return t;
    }
}
