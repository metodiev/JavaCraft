import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a static ThreadLocal without removal is flagged", () -> Main.suspiciousFields(List.of(
                "static final ThreadLocal<Context> CTX = new ThreadLocal<>();"))
                .equals(List.of("static final ThreadLocal<Context> CTX = new ThreadLocal<>();")));
        t.put("a remove call for the field clears it", () -> Main.suspiciousFields(List.of(
                "static final ThreadLocal<Context> CTX = ThreadLocal.withInitial(Context::new);",
                "CTX.remove();")).isEmpty());
        t.put("an instance ThreadLocal is ignored", () -> Main.suspiciousFields(List.of(
                "private final ThreadLocal<Context> context = new ThreadLocal<>();")).isEmpty());
        t.put("a static field that is not a ThreadLocal is ignored", () -> Main.suspiciousFields(List.of(
                "static final String NAME = \"svc\";",
                "static int counter;")).isEmpty());
        t.put("only fields without their own remove call are returned in order", () -> Main.suspiciousFields(List.of(
                "static final ThreadLocal<A> A = new ThreadLocal<>();",
                "private final ThreadLocal<B> b = new ThreadLocal<>();",
                "static ThreadLocal<C> C = new ThreadLocal<>();",
                "A.remove();")).equals(List.of("static ThreadLocal<C> C = new ThreadLocal<>();")));
        t.put("a null or empty declaration list returns an empty result", () -> Main.suspiciousFields(null).isEmpty() && Main.suspiciousFields(List.of()).isEmpty());
        t.put("null and blank declarations are ignored", () -> Main.suspiciousFields(Arrays.asList(null, "  ")).isEmpty());
        t.put("a remove call for another field does not clear this one", () -> Main.suspiciousFields(List.of(
                "static final ThreadLocal<X> X = new ThreadLocal<>();",
                "Y.remove();")).equals(List.of("static final ThreadLocal<X> X = new ThreadLocal<>();")));
        return t;
    }
}
