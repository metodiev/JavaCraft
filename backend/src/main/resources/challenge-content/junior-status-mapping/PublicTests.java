import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a created resource is 201", () -> Main.statusFor("created") == 201);
        t.put("a missing resource is 404", () -> Main.statusFor("missing") == 404);
        t.put("a state conflict is 409", () -> Main.statusFor("conflict") == 409);
        t.put("an invalid body is 422", () -> Main.statusFor("invalid") == 422);
        t.put("an unexpected failure is 500", () -> Main.statusFor("unexpected") == 500);
        t.put("outcomes are matched without regard to case", () -> Main.statusFor("CREATED") == 201 && Main.statusFor("Missing") == 404);
        t.put("an unknown outcome is 500", () -> Main.statusFor("teapot") == 500 && Main.statusFor("") == 500);
        t.put("a null outcome is 500", () -> Main.statusFor(null) == 500);
        return t;
    }
}
