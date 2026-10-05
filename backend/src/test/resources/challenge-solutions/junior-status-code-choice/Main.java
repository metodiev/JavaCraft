public class Main {
    public static int statusFor(String action) {
        if (action == null) {
            throw new IllegalArgumentException("action is required");
        }
        switch (action.trim().toLowerCase(java.util.Locale.ROOT)) {
            case "create":
                return 201;
            case "read":
                return 200;
            case "delete":
                return 204;
            case "accept":
                return 202;
            default:
                throw new IllegalArgumentException("unknown action: " + action);
        }
    }
}
