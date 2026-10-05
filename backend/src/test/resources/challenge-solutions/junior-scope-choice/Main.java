public class Main {
    public static String scopeFor(String usage) {
        if (usage == null) {
            throw new IllegalArgumentException("usage must not be null");
        }
        return switch (usage.trim()) {
            case "compile-only" -> "compile";
            case "runtime-only" -> "runtime";
            case "test-only" -> "test";
            case "provided-by-container" -> "provided";
            default -> throw new IllegalArgumentException("unknown usage: " + usage);
        };
    }
}
