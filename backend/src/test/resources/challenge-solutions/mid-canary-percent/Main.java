public class Main {
    public static int percent(int totalUsers, int minimumSample, boolean highRisk) {
        if (totalUsers < 1) {
            throw new IllegalArgumentException("totalUsers must be at least 1");
        }
        if (minimumSample < 1) {
            throw new IllegalArgumentException("minimumSample must be at least 1");
        }
        int baseline = highRisk ? 5 : 10;
        long needed = ((long) minimumSample * 100L + totalUsers - 1) / totalUsers;
        long chosen = Math.max(baseline, needed);
        return (int) Math.min(100L, Math.max(1L, chosen));
    }
}
