import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class Main {
    public static final class Repository<T, ID> {
        private final Map<ID, T> store = new HashMap<>();

        public void save(ID id, T entity) {
            store.put(id, entity);
        }

        public Optional<T> findById(ID id) {
            return Optional.ofNullable(store.get(id));
        }

        public boolean delete(ID id) {
            return store.remove(id) != null;
        }
    }
}
