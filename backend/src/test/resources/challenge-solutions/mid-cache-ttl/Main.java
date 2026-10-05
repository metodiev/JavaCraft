import java.util.Locale;

public class Main {
    public static int ttlSeconds(String dataVolatility, int acceptableStalenessSeconds, int sourceLatencyMillis) {
        if (dataVolatility == null || acceptableStalenessSeconds <= 0 || sourceLatencyMillis < 0) {
            throw new IllegalArgumentException("invalid cache ttl inputs");
        }
        int base = switch (dataVolatility.toLowerCase(Locale.ROOT)) {
            case "static" -> 86400;
            case "slow" -> 3600;
            case "fast" -> 60;
            case "realtime" -> 1;
            default -> throw new IllegalArgumentException("unknown volatility: " + dataVolatility);
        };
        int latencyFloor = (int) Math.ceil(sourceLatencyMillis / 100.0);
        int bounded = Math.min(Math.max(base, latencyFloor), acceptableStalenessSeconds);
        return Math.max(1, bounded);
    }
}
