import java.util.Map;
import java.util.Optional;

public class Main {
    public static final class Repository<T, ID> {
        public void save(ID id, T entity) {
            // TODO: store the entity under its id
        }

        public Optional<T> findById(ID id) {
            // TODO: return the stored entity or an empty optional
            return Optional.empty();
        }

        public boolean delete(ID id) {
            // TODO: remove the entity and report whether one was removed
            return false;
        }
    }
}
