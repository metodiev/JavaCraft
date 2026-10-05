import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("content type sniffing is blocked", () -> "nosniff".equals(Main.headers(false).get("X-Content-Type-Options")));
        t.put("framing is denied", () -> "DENY".equals(Main.headers(false).get("X-Frame-Options")));
        t.put("referrer is suppressed", () -> "no-referrer".equals(Main.headers(false).get("Referrer-Policy")));
        t.put("content security policy is present", () -> "default-src 'self'".equals(Main.headers(false).get("Content-Security-Policy")));
        t.put("hsts is sent over https", () -> "max-age=31536000; includeSubDomains".equals(Main.headers(true).get("Strict-Transport-Security")));
        t.put("hsts is never sent over plain http", () -> !Main.headers(false).containsKey("Strict-Transport-Security"));
        t.put("plain http response has exactly four headers", () -> Main.headers(false).equals(Map.of(
                "X-Content-Type-Options", "nosniff",
                "X-Frame-Options", "DENY",
                "Referrer-Policy", "no-referrer",
                "Content-Security-Policy", "default-src 'self'")));
        t.put("https response adds exactly one header", () -> Main.headers(true).size() == 5
                && Main.headers(true).containsKey("Strict-Transport-Security"));
        return t;
    }
}
