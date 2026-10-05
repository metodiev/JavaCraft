import java.util.*;

public class Main {
    public static final class LruCache<K, V> {
        private final int capacity;
        private final Map<K, V> entries = new LinkedHashMap<>(16, 0.75f, true);

        public LruCache(int capacity) {
            if (capacity <= 0) {
                throw new IllegalArgumentException("capacity must be positive");
            }
            this.capacity = capacity;
        }

        public V get(K key) {
            return entries.get(key);
        }

        public void put(K key, V value) {
            entries.put(key, value);
            if (entries.size() > capacity) {
                Iterator<K> oldest = entries.keySet().iterator();
                oldest.next();
                oldest.remove();
            }
        }

        public int size() {
            return entries.size();
        }
    }
}
