public class Main {
    public static String classify(String message) {
        if (message == null || message.isBlank()) {
            return "UNKNOWN";
        }
        String lower = message.toLowerCase();
        if (lower.contains("java heap space")) {
            return "HEAP";
        }
        if (lower.contains("metaspace")) {
            return "METASPACE";
        }
        if (lower.contains("gc overhead limit exceeded")) {
            return "GC_OVERHEAD";
        }
        if (lower.contains("direct buffer memory")) {
            return "DIRECT";
        }
        if (lower.contains("unable to create new native thread")
                || lower.contains("cannot reserve")
                || lower.contains("out of swap space")) {
            return "NATIVE";
        }
        if (lower.contains("map failed")) {
            return "MAP";
        }
        return "UNKNOWN";
    }
}
