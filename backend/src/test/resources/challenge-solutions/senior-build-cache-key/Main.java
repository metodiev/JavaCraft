import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

public class Main {
    public static String cacheKey(String taskName, List<String> inputs, String jdkVersion) {
        if (taskName == null || taskName.trim().isEmpty()) {
            throw new IllegalArgumentException("task name is required");
        }
        if (jdkVersion == null || jdkVersion.trim().isEmpty()) {
            throw new IllegalArgumentException("jdk version is required");
        }
        TreeSet<String> fingerprints = new TreeSet<>();
        if (inputs != null) {
            for (String input : inputs) {
                if (input != null && !input.trim().isEmpty()) {
                    fingerprints.add(input.trim());
                }
            }
        }
        StringBuilder payload = new StringBuilder();
        payload.append(taskName.trim()).append('\n').append(jdkVersion.trim()).append('\n');
        boolean first = true;
        for (String fingerprint : fingerprints) {
            if (!first) {
                payload.append('\n');
            }
            payload.append(fingerprint);
            first = false;
        }
        return sha256(payload.toString());
    }

    private static String sha256(String value) {
        try {
            byte[] digest = java.security.MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(Character.forDigit((b >> 4) & 0xF, 16));
                hex.append(Character.forDigit(b & 0xF, 16));
            }
            return hex.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
