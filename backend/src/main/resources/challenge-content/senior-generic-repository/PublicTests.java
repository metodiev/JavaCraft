import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("saves and finds an entity", () -> {
            Main.Repository<String, Integer> repo = new Main.Repository<>();
            repo.save(1, "alpha");
            return repo.findById(1).equals(Optional.of("alpha"));
        });
        t.put("missing id gives empty optional", () -> {
            Main.Repository<String, Integer> repo = new Main.Repository<>();
            repo.save(1, "alpha");
            return repo.findById(2).isEmpty();
        });
        t.put("saving the same id replaces the value", () -> {
            Main.Repository<String, Integer> repo = new Main.Repository<>();
            repo.save(1, "old");
            repo.save(1, "new");
            return repo.findById(1).equals(Optional.of("new"));
        });
        t.put("delete removes and reports true once", () -> {
            Main.Repository<String, Integer> repo = new Main.Repository<>();
            repo.save(1, "alpha");
            boolean first = repo.delete(1);
            boolean second = repo.delete(1);
            return first && !second && repo.findById(1).isEmpty();
        });
        t.put("delete of an unknown id reports false", () -> {
            Main.Repository<String, Integer> repo = new Main.Repository<>();
            return !repo.delete(42);
        });
        t.put("strings can be used as ids too", () -> {
            Main.Repository<Integer, String> repo = new Main.Repository<>();
            repo.save("k1", 7);
            return repo.findById("k1").equals(Optional.of(7));
        });
        t.put("stored values are independent per repository", () -> {
            Main.Repository<String, Integer> first = new Main.Repository<>();
            Main.Repository<String, Integer> second = new Main.Repository<>();
            first.save(1, "a");
            return second.findById(1).isEmpty();
        });
        t.put("many ids stay addressable", () -> {
            Main.Repository<String, Integer> repo = new Main.Repository<>();
            for (int i = 0; i < 10; i++) {
                repo.save(i, "v" + i);
            }
            return repo.findById(0).equals(Optional.of("v0")) && repo.findById(9).equals(Optional.of("v9"));
        });
        return t;
    }
}
