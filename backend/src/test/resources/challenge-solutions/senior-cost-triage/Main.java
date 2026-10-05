import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

public class Main {
    private record Candidate(String action, String area, double recoverable, int percent) {}

    public static List<String> actions(Map<String, Double> spendByArea) {
        if (spendByArea == null) {
            return List.of();
        }
        List<Candidate> candidates = new ArrayList<>();
        for (Map.Entry<String, Double> entry : spendByArea.entrySet()) {
            String area = entry.getKey();
            Double spend = entry.getValue();
            if (area == null || spend == null || spend <= 0 || !Double.isFinite(spend)) {
                continue;
            }
            int percent = switch (area) {
                case "idle" -> 95;
                case "logging" -> 60;
                case "egress" -> 50;
                case "storage" -> 40;
                case "compute" -> 35;
                default -> 20;
            };
            String action = switch (area) {
                case "idle" -> "shut down idle environments";
                case "logging" -> "reduce log retention and volume";
                case "egress" -> "compress and cache cross-region traffic";
                case "storage" -> "apply storage lifecycle policies";
                case "compute" -> "right-size compute instances";
                default -> "investigate " + area + " spend";
            };
            candidates.add(new Candidate(action, area, spend * percent, percent));
        }
        candidates.sort(Comparator.comparingDouble(Candidate::recoverable).reversed()
                .thenComparing(Comparator.comparingInt(Candidate::percent).reversed())
                .thenComparing(Candidate::area));
        List<String> result = new ArrayList<>(candidates.size());
        for (Candidate candidate : candidates) {
            result.add(candidate.action());
        }
        return result;
    }
}
