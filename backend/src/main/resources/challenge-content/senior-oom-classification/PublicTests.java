import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("java heap space maps to HEAP", () -> Main.classify("Java heap space").equals("HEAP"));
        t.put("metaspace maps to METASPACE", () -> Main.classify("Metaspace").equals("METASPACE")
                && Main.classify("java.lang.OutOfMemoryError: Metaspace").equals("METASPACE"));
        t.put("gc overhead maps to GC_OVERHEAD", () -> Main.classify("GC overhead limit exceeded")
                .equals("GC_OVERHEAD"));
        t.put("native memory variants map to NATIVE", () -> Main.classify("unable to create new native thread")
                .equals("NATIVE") && Main.classify("Cannot reserve 1048576 bytes").equals("NATIVE")
                && Main.classify("Out of swap space?").equals("NATIVE"));
        t.put("direct buffer memory maps to DIRECT", () -> Main.classify("Direct buffer memory").equals("DIRECT"));
        t.put("map memory maps to MAP", () -> Main.classify("Map failed").equals("MAP"));
        t.put("unknown and null messages map to UNKNOWN", () -> Main.classify("requested array size exceeds VM limit")
                .equals("UNKNOWN") && Main.classify(null).equals("UNKNOWN")
                && Main.classify("").equals("UNKNOWN") && Main.classify("   ").equals("UNKNOWN"));
        t.put("matching is case insensitive and ignores surrounding text", () -> Main.classify("java.lang.OutOfMemoryError: Java heap space")
                .equals("HEAP") && Main.classify("java heap space").equals("HEAP")
                && Main.classify("JAVA HEAP SPACE").equals("HEAP"));
        return t;
    }
}
