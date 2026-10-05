import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<String> suspiciousFields(List<String> fieldDeclarations) {
        List<String> suspicious = new ArrayList<>();
        if (fieldDeclarations == null) {
            return suspicious;
        }
        for (String declaration : fieldDeclarations) {
            if (declaration == null || declaration.isBlank()) {
                continue;
            }
            if (declaration.contains("static") && declaration.contains("ThreadLocal") && !isRemoved(declaration, fieldDeclarations)) {
                suspicious.add(declaration);
            }
        }
        return suspicious;
    }

    private static boolean isRemoved(String declaration, List<String> all) {
        String name = fieldName(declaration);
        if (name.isEmpty()) {
            return false;
        }
        for (String candidate : all) {
            if (candidate != null && candidate.contains(name + ".remove")) {
                return true;
            }
        }
        return false;
    }

    private static String fieldName(String declaration) {
        String head = declaration;
        int equals = head.indexOf('=');
        if (equals >= 0) {
            head = head.substring(0, equals);
        }
        String[] parts = head.replace(";", " ").trim().split("\\s+");
        return parts.length == 0 ? "" : parts[parts.length - 1];
    }
}
