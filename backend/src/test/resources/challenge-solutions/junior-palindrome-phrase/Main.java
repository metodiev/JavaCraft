public class Main {
    public static boolean isPalindrome(String text) {
        if (text == null || text.isBlank()) {
            return false;
        }
        int left = 0;
        int right = text.length() - 1;
        while (left < right) {
            char a = text.charAt(left);
            char b = text.charAt(right);
            if (!Character.isLetterOrDigit(a)) {
                left++;
            } else if (!Character.isLetterOrDigit(b)) {
                right--;
            } else if (Character.toLowerCase(a) != Character.toLowerCase(b)) {
                return false;
            } else {
                left++;
                right--;
            }
        }
        return true;
    }
}
