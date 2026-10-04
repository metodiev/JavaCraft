public class Main {
    public record PageRequest(int page, int size) {}

    public static long offset(PageRequest request) {
        if (request == null || request.page() < 0 || request.size() < 1 || request.size() > 100) {
            throw new IllegalArgumentException("invalid page request");
        }
        return (long) request.page() * request.size();
    }
}
