public class Main {
    public static int uniqueCount(int[] values) {
        if (values == null || values.length == 0) {
            return 0;
        }
        int write = 1;
        for (int read = 1; read < values.length; read++) {
            if (values[read] != values[write - 1]) {
                values[write] = values[read];
                write++;
            }
        }
        return write;
    }
}
