import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("the highest vendor for each release is selected", () -> {
            Map<String, List<String>> installed = new LinkedHashMap<>();
            installed.put("17", List.of("temurin", "zulu"));
            installed.put("21", List.of("graalvm"));
            Map<String, String> selection = Main.selectToolchains(List.of("17"), installed);
            return selection.size() == 1 && selection.get("17").equals("zulu")
                    && !selection.containsKey("21");
        });
        t.put("several releases are resolved independently", () -> {
            Map<String, List<String>> installed = new LinkedHashMap<>();
            installed.put("17", List.of("temurin"));
            installed.put("21", List.of("graalvm", "zulu"));
            Map<String, String> expected = new LinkedHashMap<>();
            expected.put("17", "temurin");
            expected.put("21", "zulu");
            return Main.selectToolchains(List.of("17", "21"), installed).equals(expected);
        });
        t.put("vendor names are compared as written, so zulu wins over temurin", () -> {
            Map<String, List<String>> installed = new LinkedHashMap<>();
            installed.put("8", List.of("temurin", "zulu"));
            return Main.selectToolchains(List.of("8"), installed).get("8").equals("zulu");
        });
        t.put("a release with no match is absent while the others are still selected", () -> {
            Map<String, List<String>> installed = new LinkedHashMap<>();
            installed.put("17", List.of("temurin"));
            Map<String, String> selection = Main.selectToolchains(List.of("17", "21"), installed);
            return selection.size() == 1 && selection.get("17").equals("temurin")
                    && !selection.containsKey("21");
        });
        t.put("a release with an empty vendor list is absent", () -> {
            Map<String, List<String>> installed = new LinkedHashMap<>();
            installed.put("17", List.of());
            installed.put("21", List.of("zulu"));
            Map<String, String> selection = Main.selectToolchains(List.of("17", "21"), installed);
            return selection.size() == 1 && selection.get("21").equals("zulu");
        });
        t.put("releases are reported in the requested order and repeated once", () -> {
            Map<String, List<String>> installed = new LinkedHashMap<>();
            installed.put("17", List.of("zulu"));
            installed.put("21", List.of("temurin"));
            List<String> keys = new ArrayList<>(Main.selectToolchains(List.of("21", "17"), installed).keySet());
            return keys.equals(List.of("21", "17"))
                    && Main.selectToolchains(List.of("21", "21"), installed).size() == 1;
        });
        t.put("nothing needed means nothing selected", () ->
                Main.selectToolchains(List.of(), Map.of("17", List.of("zulu"))).isEmpty()
                        && Main.selectToolchains(null, Map.of("17", List.of("zulu"))).isEmpty());
        t.put("missing data is handled without failing", () ->
                Main.selectToolchains(List.of("17"), null).isEmpty()
                        && Main.selectToolchains(List.of("17"), Map.of("17", List.of())).isEmpty()
                        && Main.selectToolchains(Arrays.asList((String) null), Map.of("17", List.of("zulu")))
                                .isEmpty()
                        && Main.selectToolchains(List.of("17"), Map.of())
                                .equals(Map.of()));
        return t;
    }
}
