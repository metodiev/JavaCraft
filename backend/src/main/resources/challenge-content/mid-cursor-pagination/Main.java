public class Main {
    public static String encode(String sortKey, String id) {
        // TODO: produce a URL-safe, unpadded base64url cursor
        return sortKey + ":" + id;
    }

    public static String[] decode(String cursor) {
        // TODO: reverse encode, returning an empty array for malformed input
        return cursor.split(":");
    }
}
