import java.util.ArrayList;
import java.util.List;

public class Main {
    private static final String SYMBOLS = "!@#$%^&*";

    public static List<String> violations(String password, int minLength) {
        List<String> found = new ArrayList<>();
        if (password == null || password.length() < minLength) {
            found.add("too short");
        }
        if (!hasUpper(password)) {
            found.add("no upper");
        }
        if (!hasLower(password)) {
            found.add("no lower");
        }
        if (!hasDigit(password)) {
            found.add("no digit");
        }
        if (!hasSymbol(password)) {
            found.add("no symbol");
        }
        return found;
    }

    private static boolean hasUpper(String password) {
        if (password == null) {
            return false;
        }
        for (int i = 0; i < password.length(); i++) {
            if (Character.isUpperCase(password.charAt(i))) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasLower(String password) {
        if (password == null) {
            return false;
        }
        for (int i = 0; i < password.length(); i++) {
            if (Character.isLowerCase(password.charAt(i))) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasDigit(String password) {
        if (password == null) {
            return false;
        }
        for (int i = 0; i < password.length(); i++) {
            if (Character.isDigit(password.charAt(i))) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasSymbol(String password) {
        if (password == null) {
            return false;
        }
        for (int i = 0; i < password.length(); i++) {
            if (SYMBOLS.indexOf(password.charAt(i)) >= 0) {
                return true;
            }
        }
        return false;
    }
}
