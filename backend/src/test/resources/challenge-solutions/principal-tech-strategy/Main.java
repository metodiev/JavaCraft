import java.util.List;

public class Main {
    private static final String[] WORDS = {"", "", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

    public static List<String> sections(int horizonYears) {
        if (horizonYears < 2 || horizonYears > 9) {
            throw new IllegalArgumentException("horizon must be between 2 and 9 years");
        }
        return List.of(
                "context and forces",
                WORDS[horizonYears] + " year horizon and outcomes",
                "principles that guide decisions",
                "options and trade-offs",
                "decision and investment",
                "measurement and review cadence");
    }
}
