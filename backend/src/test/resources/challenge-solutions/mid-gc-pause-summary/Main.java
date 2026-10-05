import java.util.List;

public class Main {
    public static String summarise(List<Integer> pauseMillis) {
        if (pauseMillis == null || pauseMillis.isEmpty()) {
            return "count=0, total=0, worst=0";
        }
        long total = 0L;
        int worst = Integer.MIN_VALUE;
        for (Integer pause : pauseMillis) {
            int value = pause == null ? 0 : pause;
            total += value;
            worst = Math.max(worst, value);
        }
        return "count=" + pauseMillis.size() + ", total=" + total + ", worst=" + worst;
    }
}
