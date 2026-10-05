import java.time.LocalDateTime;

public class Main {
    private static final int[][] RANGES = {{0, 59}, {0, 23}, {1, 31}, {1, 12}, {0, 6}};

    public static String nextRun(String cron, LocalDateTime after) {
        if (cron == null || after == null) {
            throw new IllegalArgumentException("cron and after are required");
        }
        String[] fields = cron.trim().split("\\s+");
        if (fields.length != 5) {
            throw new IllegalArgumentException("cron must have five fields: " + cron);
        }
        int[] values = new int[5];
        for (int i = 0; i < 5; i++) {
            values[i] = parseField(fields[i], i);
        }
        LocalDateTime candidate = after.withSecond(0).withNano(0).plusMinutes(1);
        for (int day = 0; day < 5000; day++) {
            boolean monthMatches = values[3] < 0 || candidate.getMonthValue() == values[3];
            boolean dayMatches = values[2] < 0 || candidate.getDayOfMonth() == values[2];
            boolean weekMatches = values[4] < 0 || candidate.getDayOfWeek().getValue() % 7 == values[4];
            if (monthMatches && dayMatches && weekMatches) {
                int start = candidate.getHour() * 60 + candidate.getMinute();
                for (int minuteOfDay = start; minuteOfDay < 24 * 60; minuteOfDay++) {
                    int hour = minuteOfDay / 60;
                    int minute = minuteOfDay % 60;
                    if ((values[1] < 0 || hour == values[1]) && (values[0] < 0 || minute == values[0])) {
                        return candidate.toLocalDate().atTime(hour, minute).toString();
                    }
                }
            }
            candidate = candidate.toLocalDate().plusDays(1).atStartOfDay();
        }
        throw new IllegalArgumentException("cron can never fire: " + cron);
    }

    private static int parseField(String field, int index) {
        if ("*".equals(field)) {
            return -1;
        }
        if (!field.matches("\\d+")) {
            throw new IllegalArgumentException("field is not a number: " + field);
        }
        int value = Integer.parseInt(field);
        if (value < RANGES[index][0] || value > RANGES[index][1]) {
            throw new IllegalArgumentException("field out of range: " + field);
        }
        return value;
    }
}
