import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("healthy topology has no findings", () -> Main.review(true, 2, true)
                .equals(List.of("topology is healthy: ownership is clear and services are sized well")));
        t.put("unclear ownership is reported", () -> Main.review(false, 2, true)
                .equals(List.of("ownership is unclear: assign one accountable team per service")));
        t.put("too many services per team is reported", () -> Main.review(true, 12, true)
                .equals(List.of("12 services per team is too many: split the team or merge the services")));
        t.put("zero services per team is reported", () -> Main.review(true, 0, true)
                .equals(List.of("0 services per team is invalid: a team must own at least one service")));
        t.put("missing platform team is reported", () -> Main.review(true, 2, false)
                .equals(List.of("no platform team: create one to own shared build, deploy and observability tooling")));
        t.put("all problems are reported together in order", () -> Main.review(false, 12, false).equals(List.of(
                "ownership is unclear: assign one accountable team per service",
                "12 services per team is too many: split the team or merge the services",
                "no platform team: create one to own shared build, deploy and observability tooling")));
        t.put("boundary of 10 services is acceptable", () -> Main.review(true, 10, true)
                .equals(List.of("topology is healthy: ownership is clear and services are sized well")));
        t.put("invalid negative services are reported like zero", () -> Main.review(true, -1, true)
                .equals(List.of("-1 services per team is invalid: a team must own at least one service")));
        return t;
    }
}
