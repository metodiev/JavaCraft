import java.util.Set;

public class Main {
    public static boolean mayStore(String region, Set<String> allowedRegions) {
        if (region == null || region.isBlank() || allowedRegions == null || allowedRegions.isEmpty()) {
            return false;
        }
        return allowedRegions.contains(region);
    }
}
