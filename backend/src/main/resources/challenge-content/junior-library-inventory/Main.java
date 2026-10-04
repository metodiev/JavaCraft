public class Main {
    private final int capacity;
    private int available;

    public Main(int capacity) {
        // TODO: reject negative capacity and initialize both fields
        this.capacity = capacity;
    }

    public boolean checkout() {
        // TODO: decrement only when a copy is available
        return false;
    }

    public boolean returnCopy() {
        // TODO: increment only below the original capacity
        return false;
    }

    public int availableCopies() {
        return available;
    }
}
