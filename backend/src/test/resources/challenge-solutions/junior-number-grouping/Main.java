public class Main {
    public static String groupDigits(long value) {
        String text = Long.toString(value);
        boolean negative = text.startsWith("-");
        String digits = negative ? text.substring(1) : text;
        StringBuilder grouped = new StringBuilder();
        for (int i = 0; i < digits.length(); i++) {
            if (i > 0 && (digits.length() - i) % 3 == 0) {
                grouped.append(',');
            }
            grouped.append(digits.charAt(i));
        }
        return (negative ? "-" : "") + grouped;
    }
}
