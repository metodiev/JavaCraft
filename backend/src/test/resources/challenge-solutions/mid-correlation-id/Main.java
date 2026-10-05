import java.util.function.Supplier;

public class Main {
    private static final int MAX_LENGTH = 64;

    public static String resolve(String inboundHeader, Supplier<String> generator) {
        if (generator == null) {
            throw new IllegalArgumentException("generator is required");
        }
        String candidate = inboundHeader == null ? "" : inboundHeader.trim();
        if (!candidate.isEmpty() && candidate.length() <= MAX_LENGTH) {
            return candidate;
        }
        String generated = generator.get();
        if (generated == null || generated.isBlank()) {
            throw new IllegalStateException("generator produced no correlation id");
        }
        return generated;
    }
}
