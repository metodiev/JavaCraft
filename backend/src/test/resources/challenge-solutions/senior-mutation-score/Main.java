import java.util.List;

public class Main {
    public static List<String> findings(int killed, int survived, int noCoverage) {
        int total = killed + survived + noCoverage;
        int score = total == 0 ? 0 : (int) Math.floor((killed * 100.0) / total + 0.5);
        String category;
        if (total == 0 || noCoverage > survived) {
            category = "weakest: NO_COVERAGE";
        } else if (score >= 80) {
            category = "strong";
        } else {
            category = "weakest: SURVIVED";
        }
        return List.of("score " + score + "%", category);
    }
}
