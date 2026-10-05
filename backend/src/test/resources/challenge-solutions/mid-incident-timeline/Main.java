import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> timeline(List<String> events) {
        if (events == null) {
            return List.of();
        }
        List<int[]> rank = new ArrayList<>();
        List<String> out = new ArrayList<>();
        for (int i = 0; i < events.size(); i++) {
            String event = events.get(i);
            int minutes = parseMinutes(event);
            out.add(event);
            rank.add(new int[] {minutes, kindRank(event), i});
        }
        Integer[] order = new Integer[out.size()];
        for (int i = 0; i < order.length; i++) {
            order[i] = i;
        }
        java.util.Arrays.sort(order, (a, b) -> {
            int[] left = rank.get(a);
            int[] right = rank.get(b);
            if (left[0] != right[0]) {
                return Integer.compare(left[0], right[0]);
            }
            if (left[1] != right[1]) {
                return Integer.compare(left[1], right[1]);
            }
            return Integer.compare(left[2], right[2]);
        });
        List<String> sorted = new ArrayList<>();
        for (int index : order) {
            sorted.add(out.get(index));
        }
        return sorted;
    }

    private static int parseMinutes(String event) {
        if (event == null || event.length() < 6 || event.charAt(2) != ':' || event.charAt(5) != ' ') {
            throw new IllegalArgumentException("event must start with HH:mm and a description");
        }
        int hour = digit(event, 0) * 10 + digit(event, 1);
        int minute = digit(event, 3) * 10 + digit(event, 4);
        if (hour > 23 || minute > 59) {
            throw new IllegalArgumentException("invalid time");
        }
        if (event.substring(6).isBlank()) {
            throw new IllegalArgumentException("description is required");
        }
        return hour * 60 + minute;
    }

    private static int digit(String event, int index) {
        char c = event.charAt(index);
        if (c < '0' || c > '9') {
            throw new IllegalArgumentException("invalid time");
        }
        return c - '0';
    }

    private static int kindRank(String event) {
        String lower = event.toLowerCase(Locale.ROOT);
        if (lower.contains("detection")) {
            return 0;
        }
        if (lower.contains("mitigation")) {
            return 1;
        }
        if (lower.contains("resolved")) {
            return 2;
        }
        return 1;
    }
}
