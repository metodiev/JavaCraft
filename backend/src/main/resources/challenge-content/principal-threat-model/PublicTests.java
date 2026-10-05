import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("no threats has no mitigations", () -> Main.mitigations(null).isEmpty() && Main.mitigations(List.of()).isEmpty());
        t.put("spoofing maps to authentication", () -> Main.mitigations(List.of("spoofing"))
                .equals(List.of("authenticate every principal before it acts")));
        t.put("all categories are ordered by risk", () -> Main.mitigations(List.of("repudiation", "denial of service", "tampering",
                "information disclosure", "spoofing", "elevation of privilege")).equals(List.of(
                "authorise every request against least privilege roles",
                "encrypt sensitive data and enforce least privilege access",
                "authenticate every principal before it acts",
                "verify integrity of data in transit and at rest",
                "apply rate limits, quotas and timeouts",
                "record tamper-evident audit logs of privileged actions")));
        t.put("input order does not matter", () -> Main.mitigations(List.of("tampering", "spoofing")).equals(List.of(
                "authenticate every principal before it acts",
                "verify integrity of data in transit and at rest")));
        t.put("duplicates produce one mitigation", () -> Main.mitigations(List.of("spoofing", "Spoofing", " spoofing "))
                .equals(List.of("authenticate every principal before it acts")));
        t.put("unknown threats are ignored", () -> Main.mitigations(List.of("quantum", "denial of service"))
                .equals(List.of("apply rate limits, quotas and timeouts")));
        t.put("matching is case insensitive and trimmed", () -> Main.mitigations(List.of(" INFORMATION DISCLOSURE "))
                .equals(List.of("encrypt sensitive data and enforce least privilege access")));
        return t;
    }
}
