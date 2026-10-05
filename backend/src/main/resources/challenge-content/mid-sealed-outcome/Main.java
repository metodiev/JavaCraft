public class Main {
    public interface Outcome {
        record Ok(String value) implements Outcome {
        }

        record Failed(String reason) implements Outcome {
        }

        static String describe(Outcome outcome) {
            // TODO: make the interface sealed and describe every case, including null
            return "";
        }
    }
}
