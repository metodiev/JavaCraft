import java.util.Map;
import java.util.Optional;

public class Main {
    public static Optional<String> cityOf(Map<String, Map<String, String>> directory, String tenant, String user) {
        return Optional.ofNullable(directory)
                .flatMap(map -> Optional.ofNullable(map.get(tenant)))
                .flatMap(users -> Optional.ofNullable(users.get(user)))
                .filter(city -> !city.isBlank());
    }
}
