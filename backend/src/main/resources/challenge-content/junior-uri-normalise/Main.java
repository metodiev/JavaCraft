public class Main {
    public static String normalise(String path) {
        // TODO: collapse slashes, resolve dot segments and drop the trailing slash
        if (path == null || path.isEmpty()) {
            return "/";
        }
        return path;
    }
}
