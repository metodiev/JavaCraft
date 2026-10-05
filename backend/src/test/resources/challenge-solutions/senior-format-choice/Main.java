public class Main {
    public static String format(boolean humanReadable, boolean schemaEvolution,
                                boolean highVolume, boolean browserClient) {
        if (browserClient || humanReadable || !highVolume) {
            return "JSON";
        }
        return schemaEvolution ? "AVRO" : "PROTOBUF";
    }
}
