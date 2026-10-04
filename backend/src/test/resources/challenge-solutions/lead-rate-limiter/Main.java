import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

public class Main {
    private record Counter(long window, int count) {}

    private final int limit;
    private final long windowMillis;
    private final int maxTenants;
    private final Map<String, Counter> counters = new HashMap<>();

    public Main(int limit, Duration window, int maxTenants) {
        if (limit < 1 || window == null || window.toMillis() < 1 || maxTenants < 1) {
            throw new IllegalArgumentException("invalid configuration");
        }
        this.limit = limit;
        this.windowMillis = window.toMillis();
        this.maxTenants = maxTenants;
    }

    public synchronized boolean allow(String tenant, Instant now) {
        if (tenant == null || now == null) {
            throw new IllegalArgumentException("tenant and time are required");
        }
        long currentWindow = Math.floorDiv(now.toEpochMilli(), windowMillis);
        Counter existing = counters.get(tenant);
        if (existing == null) {
            counters.values().removeIf(c -> c.window() < currentWindow);
            if (counters.size() >= maxTenants) {
                return false;
            }
            counters.put(tenant, new Counter(currentWindow, 1));
            return true;
        }
        if (existing.window() < currentWindow) {
            counters.put(tenant, new Counter(currentWindow, 1));
            return true;
        }
        if (existing.count() >= limit) {
            return false;
        }
        counters.put(tenant, new Counter(existing.window(), existing.count() + 1));
        return true;
    }
}
