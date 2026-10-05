public class Main {
    public static String scheduler(String workload) {
        if (workload == null) {
            throw new IllegalArgumentException("workload must not be null");
        }
        return switch (workload.trim().toLowerCase()) {
            case "cpu" -> "parallel";
            case "blocking" -> "boundedElastic";
            case "legacy" -> "elastic";
            case "single" -> "single";
            case "immediate" -> "immediate";
            default -> throw new IllegalArgumentException("unknown workload: " + workload);
        };
    }
}
