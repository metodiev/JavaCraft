import java.util.*;

public class Main {
    private static final Set<String> DEPRECATED = Set.of("sslv3", "tlsv1", "tlsv1.0", "tlsv1.1");
    private static final List<String> WEAK_MARKERS = List.of("_RC4_", "_3DES_", "_DES_", "_NULL_", "EXPORT");

    public static List<String> violations(String protocol, String cipherSuite, boolean verifyHostname, boolean verifyChain) {
        if (protocol == null || cipherSuite == null) {
            throw new IllegalArgumentException("protocol and cipher suite are required");
        }
        List<String> findings = new ArrayList<>();
        if (DEPRECATED.contains(protocol.trim().toLowerCase(Locale.ROOT))) {
            findings.add("deprecated protocol: " + protocol);
        }
        String upperCipher = cipherSuite.toUpperCase(Locale.ROOT);
        for (String marker : WEAK_MARKERS) {
            if (upperCipher.contains(marker)) {
                findings.add("weak cipher suite: " + cipherSuite);
                break;
            }
        }
        if (!verifyHostname) {
            findings.add("hostname verification disabled");
        }
        if (!verifyChain) {
            findings.add("certificate chain verification disabled");
        }
        Collections.sort(findings);
        return findings;
    }
}
