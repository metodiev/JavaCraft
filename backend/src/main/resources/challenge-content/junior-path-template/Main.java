import java.util.List;

public class Main {
    public static String path(String base, List<String> segments) {
        // TODO: join the segments with single slashes and encode spaces
        StringBuilder out = new StringBuilder(base == null ? "" : base);
        if (segments != null) {
            for (String segment : segments) {
                out.append('/').append(segment);
            }
        }
        return out.toString();
    }
}
