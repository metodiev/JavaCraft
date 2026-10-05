import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Main {
    public static String etag(byte[] body, int version) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(body == null ? new byte[0] : body);
            digest.update(Integer.toString(version).getBytes(StandardCharsets.US_ASCII));
            StringBuilder hex = new StringBuilder("\"");
            for (byte b : digest.digest()) {
                hex.append(Character.forDigit((b >> 4) & 0xF, 16));
                hex.append(Character.forDigit(b & 0xF, 16));
            }
            return hex.append('"').toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 is required", e);
        }
    }
}
