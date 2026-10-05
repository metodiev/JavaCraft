import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("equal versions compare as zero", () -> Main.compareReleases("17.0.1", "17.0.1") == 0);
        t.put("major version dominates", () -> Main.compareReleases("21.0.0", "17.9.9") > 0
                && Main.compareReleases("8.9.9", "11.0.0") < 0);
        t.put("minor version is compared before patch", () -> Main.compareReleases("17.1.0", "17.0.9") > 0
                && Main.compareReleases("17.0.9", "17.1.0") < 0);
        t.put("patch version is compared numerically", () -> Main.compareReleases("17.0.10", "17.0.9") > 0);
        t.put("missing components count as zero", () -> Main.compareReleases("17", "17.0.0") == 0
                && Main.compareReleases("17.0", "17.0.0") == 0);
        t.put("legacy prefix is ignored", () -> Main.compareReleases("1.8.0_292", "8.0.292") == 0
                && Main.compareReleases("1.8.0_292", "1.8.0_292") == 0
                && Main.compareReleases("1.8.0_292", "8.0.0") > 0
                && Main.compareReleases("1.8.0_292", "11") < 0);
        t.put("underscore separates the patch", () -> Main.compareReleases("8.0_292", "8.0.300") < 0
                && Main.compareReleases("8.0_292", "1.8.0_292") == 0);
        t.put("null and blank are oldest", () -> Main.compareReleases(null, "8") < 0
                && Main.compareReleases("", null) == 0
                && Main.compareReleases("   ", "0.0.0") == 0);
        return t;
    }
}
