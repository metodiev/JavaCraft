import java.util.HashMap;
import java.util.Map;

public class Main {
    public static Map<String, Double> autovacuumSettings(long tableRows, double updateRatio) {
        // TODO: scale the vacuum settings down as churn rises
        Map<String, Double> settings = new HashMap<>();
        settings.put("vacuum_scale_factor", 0.2);
        settings.put("vacuum_threshold", 50.0);
        settings.put("vacuum_trigger_rows", 50 + 0.2 * tableRows);
        settings.put("analyze_scale_factor", 0.1);
        return settings;
    }
}
