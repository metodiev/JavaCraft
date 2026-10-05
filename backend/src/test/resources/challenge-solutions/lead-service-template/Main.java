import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> baselineComponents(boolean exposesApi, boolean writesData, boolean runsInProduction) {
        List<String> components = new ArrayList<>();
        components.add("spring-boot-starter-web");
        components.add("spring-boot-starter-actuator");
        components.add("structured logging with a correlation id");
        if (exposesApi) {
            components.add("spring-boot-starter-validation");
            components.add("RFC 9457 problem details error contract");
        }
        if (writesData) {
            components.add("spring-boot-starter-data-jpa");
            components.add("database migrations managed by flyway or liquibase");
        }
        if (runsInProduction) {
            components.add("spring-boot-starter-security");
            components.add("micrometer metrics with alert thresholds");
            components.add("liveness and readiness health probes");
        }
        return components;
    }
}
