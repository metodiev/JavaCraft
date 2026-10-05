import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("classifies the informational range", () -> Main.classify(100).equals("INFORMATIONAL")
                && Main.classify(199).equals("INFORMATIONAL"));
        t.put("classifies the success range", () -> Main.classify(200).equals("SUCCESS")
                && Main.classify(299).equals("SUCCESS"));
        t.put("classifies the redirect range", () -> Main.classify(301).equals("REDIRECT")
                && Main.classify(304).equals("REDIRECT"));
        t.put("classifies the client error range", () -> Main.classify(400).equals("CLIENT_ERROR")
                && Main.classify(429).equals("CLIENT_ERROR"));
        t.put("classifies the server error range", () -> Main.classify(500).equals("SERVER_ERROR")
                && Main.classify(503).equals("SERVER_ERROR"));
        t.put("unassigned codes fall outside the ranges", () -> Main.classify(0).equals("UNKNOWN")
                && Main.classify(99).equals("UNKNOWN") && Main.classify(600).equals("UNKNOWN")
                && Main.classify(-1).equals("UNKNOWN"));
        t.put("custom codes use their class", () -> Main.classify(218).equals("SUCCESS")
                && Main.classify(567).equals("SERVER_ERROR"));
        t.put("class names are exact", () -> !Main.classify(200).equals("OK") && !Main.classify(404).equals("NOT_FOUND")
                && Main.classify(399).equals("REDIRECT"));
        return t;
    }
}
