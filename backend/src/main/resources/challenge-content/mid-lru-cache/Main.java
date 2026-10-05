import java.util.*;

public class Main {
    public static final class LruCache<K, V> {
        private final int capacity;

        public LruCache(int capacity) {
            this.capacity = capacity;
        }

        public V get(K key) {
            // TODO: return the value, marking the entry as most recently used
            return null;
        }

        public void put(K key, V value) {
            // TODO: insert or update, evicting the least recently used entry when full
        }

        public int size() {
            // TODO: report how many entries are cached
            return 0;
        }
    }
}
