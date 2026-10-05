import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an implicit project access is a violation", () ->
                Main.violations(List.of("project.name")).equals(List.of("project.name")));
        t.put("the Project type is a violation", () ->
                Main.violations(List.of("Project owner = project;")).equals(List.of("Project owner = project;")));
        t.put("getProject() is a violation", () ->
                Main.violations(List.of("String n = getProject().getName();"))
                        .equals(List.of("String n = getProject().getName();")));
        t.put("reading the environment is a violation", () ->
                Main.violations(List.of("String home = System.getenv(\"HOME\");"))
                        .equals(List.of("String home = System.getenv(\"HOME\");")));
        t.put("the supported alternatives are not violations", () ->
                Main.violations(List.of(
                        "providers.environmentVariable(\"HOME\").get()",
                        "projectDir.resolve(\"build\")",
                        "layout.buildDirectory.dir(\"out\")",
                        "providers.gradleProperty(\"release\").get()"))
                        .isEmpty());
        t.put("results are sorted and de-duplicated", () ->
                Main.violations(List.of(
                        "System.getenv(\"HOME\")",
                        "project.name",
                        "  project.name  ",
                        "Project owner = project;"))
                        .equals(List.of("Project owner = project;", "System.getenv(\"HOME\")", "project.name")));
        t.put("surrounding whitespace is trimmed from the report", () ->
                Main.violations(List.of("   System.getenv(\"HOME\")   "))
                        .equals(List.of("System.getenv(\"HOME\")")));
        t.put("blank and null entries are ignored", () ->
                Main.violations(Arrays.asList("   ", null)).isEmpty()
                        && Main.violations(null).isEmpty()
                        && Main.violations(List.of()).isEmpty());
        t.put("clean task lines produce an empty report", () ->
                Main.violations(List.of(
                        "tasks.register(\"hello\") {",
                        "    doLast {",
                        "        println(\"hi\")",
                        "    }",
                        "}"))
                        .isEmpty());
        return t;
    }
}
