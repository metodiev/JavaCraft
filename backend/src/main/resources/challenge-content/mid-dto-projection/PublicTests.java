import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Object> entity = new LinkedHashMap<>();
        entity.put("id", 7L);
        entity.put("name", "Ada");
        entity.put("email", "ada@example.com");
        entity.put("password", "hunter2");
        entity.put("nickname", null);

        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("only the requested fields are copied, in request order",
                () -> new ArrayList<>(Main.projection(List.of("name", "id"), entity).keySet())
                        .equals(List.of("name", "id")));
        t.put("the requested values are the entity values",
                () -> Main.projection(List.of("email"), entity).get("email").equals("ada@example.com"));
        t.put("unknown fields are skipped",
                () -> Main.projection(List.of("name", "nope"), entity).equals(Map.of("name", "Ada")));
        t.put("null values are skipped",
                () -> !Main.projection(List.of("nickname", "name"), entity).containsKey("nickname"));
        t.put("a password field is never projected",
                () -> !Main.projection(List.of("password", "name"), entity).containsKey("password")
                        && !Main.projection(List.of("password"), entity).containsKey("password"));
        t.put("an empty or null request projects nothing",
                () -> Main.projection(List.of(), entity).isEmpty()
                        && Main.projection(null, entity).isEmpty()
                        && Main.projection(List.of("name"), null).isEmpty());
        t.put("duplicate requests keep the first position once",
                () -> new ArrayList<>(Main.projection(List.of("id", "name", "id"), entity).keySet())
                        .equals(List.of("id", "name")));
        t.put("the entity map is not modified", () -> {
            Map<String, Object> copy = new LinkedHashMap<>(entity);
            Main.projection(List.of("name", "password"), entity);
            return entity.equals(copy) && entity.containsKey("password");
        });
        return t;
    }
}
