import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("dependency resolution moves before the source copy", () -> {
            List<String> out = Main.optimise(List.of("FROM eclipse-temurin:21-jdk",
                    "COPY . .", "RUN mvn dependency:go-offline", "RUN mvn package"));
            return out.equals(List.of("FROM eclipse-temurin:21-jdk", "RUN mvn dependency:go-offline",
                    "COPY . .", "RUN mvn package"));
        });
        t.put("already ordered instructions are unchanged", () -> {
            List<String> input = List.of("FROM eclipse-temurin:21-jdk", "COPY pom.xml .",
                    "RUN mvn dependency:go-offline", "COPY src ./src", "RUN mvn package");
            return Main.optimise(input).equals(input);
        });
        t.put("go-offline is treated as dependency resolution", () -> {
            List<String> out = Main.optimise(List.of("COPY src ./src", "RUN ./mvnw -B go-offline"));
            return out.equals(List.of("RUN ./mvnw -B go-offline", "COPY src ./src"));
        });
        t.put("all moved dependencies keep their relative order", () -> {
            List<String> out = Main.optimise(List.of("COPY . .", "RUN mvn dependency:resolve",
                    "RUN mvn dependency:go-offline", "RUN mvn package"));
            return out.equals(List.of("RUN mvn dependency:resolve", "RUN mvn dependency:go-offline",
                    "COPY . .", "RUN mvn package"));
        });
        t.put("instructions without a source copy are unchanged", () -> {
            List<String> input = List.of("FROM eclipse-temurin:21-jdk", "RUN mvn dependency:go-offline",
                    "CMD java -jar app.jar");
            return Main.optimise(input).equals(input);
        });
        t.put("the input list is not modified", () -> {
            List<String> input = new ArrayList<>(List.of("COPY . .", "RUN mvn dependency:go-offline"));
            Main.optimise(input);
            return input.equals(List.of("COPY . .", "RUN mvn dependency:go-offline"));
        });
        t.put("null input returns an empty list", () -> Main.optimise(null).isEmpty());
        t.put("empty input returns an empty list", () -> Main.optimise(List.of()).isEmpty());
        return t;
    }
}
