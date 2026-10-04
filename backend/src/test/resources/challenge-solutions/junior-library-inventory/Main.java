public class Main {
    private final int capacity;
    private int available;

    public Main(int capacity) {
        if (capacity < 0) {
            throw new IllegalArgumentException("capacity must not be negative");
        }
        this.capacity = capacity;
        this.available = capacity;
    }

    public boolean checkout() {
        if (available == 0) {
            return false;
        }
        available--;
        return true;
    }

    public boolean returnCopy() {
        if (available >= capacity) {
            return false;
        }
        available++;
        return true;
    }

    public int availableCopies() {
        return available;
    }
}
