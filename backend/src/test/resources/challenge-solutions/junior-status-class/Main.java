public class Main {
    public static String classify(int status) {
        if (status >= 100 && status < 200) {
            return "INFORMATIONAL";
        }
        if (status >= 200 && status < 300) {
            return "SUCCESS";
        }
        if (status >= 300 && status < 400) {
            return "REDIRECT";
        }
        if (status >= 400 && status < 500) {
            return "CLIENT_ERROR";
        }
        if (status >= 500 && status < 600) {
            return "SERVER_ERROR";
        }
        return "UNKNOWN";
    }
}
