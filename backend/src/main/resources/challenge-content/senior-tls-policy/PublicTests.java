import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a modern stack has no violations", () -> Main.violations("TLSv1.3", "TLS_AES_128_GCM_SHA256", true, true).isEmpty());
        t.put("tls 1.2 with a strong cipher is acceptable", () -> Main.violations("TLSv1.2",
                "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", true, true).isEmpty());
        t.put("legacy protocol names are flagged", () -> List.of("deprecated protocol: TLSv1.1")
                .equals(Main.violations("TLSv1.1", "TLS_AES_256_GCM_SHA384", true, true))
                && Main.violations("SSLv3", "TLS_AES_256_GCM_SHA384", true, true)
                        .equals(List.of("deprecated protocol: SSLv3")));
        t.put("weak cipher families are flagged", () -> List.of("weak cipher suite: TLS_RSA_WITH_3DES_EDE_CBC_SHA")
                .equals(Main.violations("TLSv1.2", "TLS_RSA_WITH_3DES_EDE_CBC_SHA", true, true))
                && List.of("weak cipher suite: TLS_RSA_WITH_RC4_128_SHA")
                        .equals(Main.violations("TLSv1.2", "TLS_RSA_WITH_RC4_128_SHA", true, true))
                && List.of("weak cipher suite: TLS_RSA_EXPORT_WITH_RC4_40_MD5")
                        .equals(Main.violations("TLSv1.2", "TLS_RSA_EXPORT_WITH_RC4_40_MD5", true, true))
                && List.of("weak cipher suite: TLS_RSA_WITH_NULL_SHA")
                        .equals(Main.violations("TLSv1.2", "TLS_RSA_WITH_NULL_SHA", true, true)));
        t.put("missing hostname verification is flagged", () -> List.of("hostname verification disabled")
                .equals(Main.violations("TLSv1.3", "TLS_AES_128_GCM_SHA256", false, true)));
        t.put("missing chain verification is flagged", () -> List.of("certificate chain verification disabled")
                .equals(Main.violations("TLSv1.3", "TLS_AES_128_GCM_SHA256", true, false)));
        t.put("findings for one policy are sorted", () -> List.of("certificate chain verification disabled",
                "hostname verification disabled").equals(Main.violations("TLSv1.3", "TLS_AES_128_GCM_SHA256", false, false))
                && List.of("certificate chain verification disabled", "deprecated protocol: TLSv1.1",
                        "hostname verification disabled", "weak cipher suite: TLS_RSA_WITH_3DES_EDE_CBC_SHA")
                        .equals(Main.violations("TLSv1.1", "TLS_RSA_WITH_3DES_EDE_CBC_SHA", false, false)));
        t.put("null inputs are rejected", () -> {
            try {
                Main.violations(null, "TLS_AES_128_GCM_SHA256", true, true);
                return false;
            } catch (IllegalArgumentException e) {
                // fall through to the second check
            }
            try {
                Main.violations("TLSv1.3", null, true, true);
                return false;
            } catch (IllegalArgumentException e) {
                return true;
            }
        });
        return t;
    }
}
