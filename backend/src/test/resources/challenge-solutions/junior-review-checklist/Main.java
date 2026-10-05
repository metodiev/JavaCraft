import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> checks(int changedLines, boolean hasTests, boolean touchesConfig) {
        if (changedLines < 1) {
            throw new IllegalArgumentException("changedLines must be at least 1");
        }
        List<String> out = new ArrayList<>();
        out.add("readability and naming");
        out.add("tests cover the change");
        if (!hasTests) {
            out.add("add or update tests");
        }
        if (touchesConfig) {
            out.add("check configuration and environment impact");
        }
        if (changedLines > 200) {
            out.add("split the change or review in small commits");
        }
        return out;
    }
}
