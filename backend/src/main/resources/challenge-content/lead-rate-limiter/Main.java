import java.time.Duration;
import java.time.Instant;

public class Main {
    public Main(int limit, Duration window, int maxTenants) {
        // TODO: validate and store configuration
    }

    public boolean allow(String tenant, Instant now) {
        // TODO: fixed epoch-aligned windows with bounded tenant memory
        return true;
    }
}
