import java.util.List;

public class Main {
    public static List<String> orderedFilters() {
        return List.of(
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
                "AuthorizationFilter");
    }
}
