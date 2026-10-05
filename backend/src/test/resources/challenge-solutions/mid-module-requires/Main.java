import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

public class Main {
    public static List<String> requires(List<String> importedPackages) {
        TreeSet<String> modules = new TreeSet<>();
        if (importedPackages != null) {
            for (String pkg : importedPackages) {
                if (pkg != null) {
                    modules.add(moduleFor(pkg));
                }
            }
        }
        List<String> result = new ArrayList<>();
        result.add("java.base");
        for (String module : modules) {
            if (!module.equals("java.base")) {
                result.add(module);
            }
        }
        return result;
    }

    private static String moduleFor(String pkg) {
        if (matches(pkg, "java.sql") || matches(pkg, "javax.sql")) {
            return "java.sql";
        }
        if (matches(pkg, "java.awt") || matches(pkg, "javax.swing")) {
            return "java.desktop";
        }
        if (matches(pkg, "java.util.logging")) {
            return "java.logging";
        }
        if (matches(pkg, "javax.xml") || matches(pkg, "org.w3c.dom")) {
            return "java.xml";
        }
        if (matches(pkg, "java.lang.management") || matches(pkg, "javax.management")) {
            return "java.management";
        }
        if (matches(pkg, "java.net.http")) {
            return "java.net.http";
        }
        return "java.base";
    }

    private static boolean matches(String pkg, String prefix) {
        return pkg.equals(prefix) || pkg.startsWith(prefix + ".");
    }
}
