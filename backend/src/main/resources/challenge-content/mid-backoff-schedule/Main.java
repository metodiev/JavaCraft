import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<Long> backoffMillis(int attempts, long base, long cap) {
        // TODO: double each delay and clamp it to cap
        List<Long> delays = new ArrayList<>();
        for (int i = 0; i < attempts; i++) {
            delays.add(base);
        }
        return delays;
    }
}
