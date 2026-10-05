import java.util.*;

public class Main {
    public static final class ConcurrentLruCache<K, V> {
        private final int capacity;
        private final LinkedHashMap<K, V> entries;

        public ConcurrentLruCache(int capacity) {
            if (capacity <= 0) {
                throw new IllegalArgumentException("capacity must be positive");
            }
            this.capacity = capacity;
            this.entries = new LinkedHashMap<>(16, 0.75f, true);
        }

        public synchronized V get(K key) {
            return entries.get(key);
        }

        public synchronized void put(K key, V value) {
            entries.put(key, value);
            if (entries.size() > capacity) {
                Iterator<K> oldest = entries.keySet().iterator();
                oldest.next();
                oldest.remove();
            }
        }

        public synchronized int size() {
            return entries.size();
        }
    }
}
