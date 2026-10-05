public class Main {
    public static String etag(byte[] body, int version) {
        // TODO: hash the body together with the version into a strong quoted ETag
        return "\"" + (body == null ? 0 : body.length) + "\"";
    }
}
