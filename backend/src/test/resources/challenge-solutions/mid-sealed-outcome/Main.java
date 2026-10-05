public class Main {
    public sealed interface Outcome permits Outcome.Ok, Outcome.Failed {
        record Ok(String value) implements Outcome {
        }

        record Failed(String reason) implements Outcome {
        }

        static String describe(Outcome outcome) {
            if (outcome == null) {
                return "unknown outcome";
            }
            return switch (outcome) {
                case Ok ok -> "ok: " + display(ok.value());
                case Failed failed -> "failed: " + display(failed.reason());
            };
        }

        private static String display(String text) {
            return text == null || text.isBlank() ? "(none)" : text;
        }
    }
}
