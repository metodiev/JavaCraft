import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("returns exactly the fifteen documented filters", () -> Main.orderedFilters().equals(List.of(
                "DisableEncodeUrlFilter",
                "WebAsyncManagerIntegrationFilter",
                "SecurityContextHolderFilter",
                "HeaderWriterFilter",
                "CorsFilter",
                "CsrfFilter",
                "LogoutFilter",
                "UsernamePasswordAuthenticationFilter",
                "DefaultLoginPageGeneratingFilter",
                "BasicAuthenticationFilter",
                "RequestCacheAwareFilter",
                "SecurityContextHolderAwareRequestFilter",
                "AnonymousAuthenticationFilter",
                "ExceptionTranslationFilter",
                "AuthorizationFilter")));
        t.put("the security context holder runs before the header writer", () ->
                index("SecurityContextHolderFilter") < index("HeaderWriterFilter"));
        t.put("cors runs before csrf and csrf before logout", () ->
                index("CorsFilter") < index("CsrfFilter") && index("CsrfFilter") < index("LogoutFilter"));
        t.put("logout runs before form login", () ->
                index("LogoutFilter") < index("UsernamePasswordAuthenticationFilter"));
        t.put("authentication runs before authorization", () ->
                index("UsernamePasswordAuthenticationFilter") < index("AuthorizationFilter")
                        && index("BasicAuthenticationFilter") < index("AuthorizationFilter"));
        t.put("anonymous authentication precedes exception translation", () ->
                index("AnonymousAuthenticationFilter") < index("ExceptionTranslationFilter"));
        t.put("exception translation wraps the authorization filter", () ->
                index("ExceptionTranslationFilter") < index("AuthorizationFilter"));
        t.put("the authorization filter is last", () ->
                index("AuthorizationFilter") == Main.orderedFilters().size() - 1);
        t.put("the result is stable across calls", () -> Main.orderedFilters().equals(Main.orderedFilters()));
        return t;
    }

    private static int index(String filter) {
        return Main.orderedFilters().indexOf(filter);
    }
}
