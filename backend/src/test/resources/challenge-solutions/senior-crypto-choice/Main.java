public class Main {
    public static String primitive(String purpose) {
        if (purpose == null) {
            throw new IllegalArgumentException("purpose is required");
        }
        switch (purpose) {
            case "password-storage":
                return "hashing";
            case "data-at-rest":
                return "symmetric encryption";
            case "message-integrity":
                return "MAC";
            case "session-key":
                return "key exchange";
            default:
                throw new IllegalArgumentException("unknown purpose: " + purpose);
        }
    }
}
