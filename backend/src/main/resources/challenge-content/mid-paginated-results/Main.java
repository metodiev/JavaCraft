public class Main {
    public record PageRequest(int page, int size) {}

    public static long offset(PageRequest request) {
        // TODO: validate and compute the row offset
        return request.page() * request.size();
    }
}
