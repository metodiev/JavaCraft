import java.util.HashMap;
import java.util.Map;

public class Main {
    public static Map<String, Double> autovacuumSettings(long tableRows, double updateRatio) {
        if (tableRows < 0 || !(updateRatio >= 0 && updateRatio <= 1)) {
            throw new IllegalArgumentException("invalid autovacuum arguments");
        }
        double vacuumScale = Math.max(0.01, 0.2 * (1 - updateRatio));
        double vacuumThreshold = Math.max(20, 50 - 30 * updateRatio);
        double analyzeScale = Math.max(0.005, 0.1 * (1 - updateRatio));
        Map<String, Double> settings = new HashMap<>();
        settings.put("vacuum_scale_factor", vacuumScale);
        settings.put("vacuum_threshold", vacuumThreshold);
        settings.put("vacuum_trigger_rows", Math.floor(vacuumThreshold + vacuumScale * tableRows));
        settings.put("analyze_scale_factor", analyzeScale);
        return settings;
    }
}
