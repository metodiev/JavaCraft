import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("matches the sha-256 of body plus version", () -> {
            byte[] body = "hello".getBytes(java.nio.charset.StandardCharsets.UTF_8);
            return expectedEtag(body, 7).equals(Main.etag(body, 7));
        });
        t.put("is stable for the same input", () -> Main.etag("same".getBytes(), 3).equals(Main.etag("same".getBytes(), 3)));
        t.put("different versions produce different etags", () -> !Main.etag("same".getBytes(), 1).equals(Main.etag("same".getBytes(), 2)));
        t.put("different bodies produce different etags", () -> !Main.etag("a".getBytes(), 1).equals(Main.etag("b".getBytes(), 1)));
        t.put("empty body returns a quoted sixty four digit hash", () -> {
            String tag = Main.etag(new byte[0], 0);
            return tag.length() == 66 && tag.startsWith("\"") && tag.endsWith("\"") && isLowerHex(tag.substring(1, 65));
        });
        t.put("null body is treated as empty", () -> Main.etag(null, 5).equals(expectedEtag(new byte[0], 5)));
        t.put("etag is strong and not weak", () -> !Main.etag(null, 1).startsWith("W/"));
        return t;
    }

    private static String expectedEtag(byte[] body, int version) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            digest.update(body == null ? new byte[0] : body);
            digest.update(Integer.toString(version).getBytes(java.nio.charset.StandardCharsets.US_ASCII));
            StringBuilder hex = new StringBuilder("\"");
            for (byte b : digest.digest()) {
                hex.append(Character.forDigit((b >> 4) & 0xF, 16)).append(Character.forDigit(b & 0xF, 16));
            }
            return hex.append('"').toString();
        } catch (Exception e) {
            return null;
        }
    }

    private static boolean isLowerHex(String value) {
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            if ((c < '0' || c > '9') && (c < 'a' || c > 'f')) {
                return false;
            }
        }
        return !value.isEmpty();
    }
}
