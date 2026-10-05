public class Main {
    public static String strength(String password) {
        if (password == null || password.length() < 8) {
            return "WEAK";
        }
        boolean lower = false;
        boolean upper = false;
        boolean digit = false;
        boolean symbol = false;
        for (int i = 0; i < password.length(); i++) {
            char c = password.charAt(i);
            if (Character.isLetter(c)) {
                if (Character.isUpperCase(c)) {
                    upper = true;
                } else {
                    lower = true;
                }
            } else if (Character.isDigit(c)) {
                digit = true;
            } else {
                symbol = true;
            }
        }
        int classes = 0;
        if (lower) {
            classes++;
        }
        if (upper) {
            classes++;
        }
        if (digit) {
            classes++;
        }
        if (symbol) {
            classes++;
        }
        if (password.length() >= 12 && classes >= 3) {
            return "STRONG";
        }
        if (password.length() >= 10 && classes >= 2) {
            return "GOOD";
        }
        return "FAIR";
    }
}
