import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> measures(boolean hasBuildToolsInRuntime, boolean multiStage, String baseImage) {
        List<String> result = new ArrayList<>();
        if (!multiStage && hasBuildToolsInRuntime) {
            result.add("use a multi-stage build");
        } else if (hasBuildToolsInRuntime) {
            result.add("remove build tools from the runtime image");
        }
        if (baseImage != null) {
            String image = baseImage.toLowerCase(Locale.ROOT);
            if (image.contains("jdk") || (image.contains("openjdk") && !image.contains("jre"))) {
                result.add("use a JRE base image");
            }
            boolean slim = image.contains("slim") || image.contains("alpine") || image.contains("distroless");
            if (!slim) {
                result.add("use a slim base image");
            }
        }
        return result;
    }
}
