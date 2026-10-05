import java.util.ArrayList;
import java.util.List;

public class Main {
    public static List<Long> backoffMillis(int attempts, long base, long cap) {
        if (base <= 0) {
            throw new IllegalArgumentException("base must be positive");
        }
        if (cap <= 0) {
            throw new IllegalArgumentException("cap must be positive");
        }
        List<Long> delays = new ArrayList<>();
        long delay = Math.min(base, cap);
        for (int i = 0; i < attempts; i++) {
            delays.add(delay);
            if (delay >= cap - delay) {
                delay = cap;
            } else {
                delay = delay * 2;
            }
        }
        return delays;
    }
}
