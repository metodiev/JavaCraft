import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Set;

public class Main {
    private static final Set<String> GADGETS = Set.of(
            "javax.naming.InitialContext",
            "com.sun.rowset.JdbcRowSetImpl");

    public static List<String> violations(String className, Set<String> allowedPackages) {
        if (className == null || allowedPackages == null) {
            throw new IllegalArgumentException("className and allowedPackages must not be null");
        }
        List<String> violations = new ArrayList<>();
        if (className.startsWith("java.io.")) {
            violations.add("native-serialization");
        }
        if (GADGETS.contains(className)) {
            violations.add("dangerous-gadget");
        }
        if (!allowed(className, allowedPackages)) {
            violations.add("package-not-allowed");
        }
        Collections.sort(violations);
        return violations;
    }

    private static boolean allowed(String className, Set<String> allowedPackages) {
        int lastDot = className.lastIndexOf('.');
        if (lastDot < 0) {
            return false;
        }
        String pkg = className.substring(0, lastDot);
        for (String allowed : allowedPackages) {
            if (pkg.equals(allowed) || pkg.startsWith(allowed + ".")) {
                return true;
            }
        }
        return false;
    }
}
