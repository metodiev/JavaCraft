public class Main {
    public static String classify(int status) {
        // TODO: map the numeric status to its standard class name
        return status == 200 ? "SUCCESS" : "UNKNOWN";
    }
}
