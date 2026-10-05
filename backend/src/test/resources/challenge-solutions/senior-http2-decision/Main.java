public class Main {
    public static String advise(int concurrentRequests, boolean headOfLineBlocking, boolean serverPush) {
        if (concurrentRequests < 0) {
            throw new IllegalArgumentException("concurrent requests must not be negative");
        }
        if (concurrentRequests >= 100 || headOfLineBlocking) {
            return "enable http/2";
        }
        if (serverPush) {
            return "avoid server push";
        }
        return "keep http/1.1";
    }
}
