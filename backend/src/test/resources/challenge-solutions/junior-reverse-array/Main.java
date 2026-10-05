public class Main {
    public static void reverse(int[] values) {
        if (values == null) {
            return;
        }
        for (int left = 0, right = values.length - 1; left < right; left++, right--) {
            int swapped = values[left];
            values[left] = values[right];
            values[right] = swapped;
        }
    }
}
