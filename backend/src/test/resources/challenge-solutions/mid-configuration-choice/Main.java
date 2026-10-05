public class Main {
    public static String configurationFor(String usage, boolean publishedLibrary) {
        if (usage == null) {
            throw new IllegalArgumentException("usage is required");
        }
        switch (usage) {
            case "api":
                return publishedLibrary ? "api" : "implementation";
            case "internal":
                return "implementation";
            case "runtime":
                return "runtimeOnly";
            case "test":
                return "testImplementation";
            default:
                throw new IllegalArgumentException("unknown usage: " + usage);
        }
    }
}
