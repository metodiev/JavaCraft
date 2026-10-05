import java.util.List;

public class Main {
    public static int replay(List<String> events, int initialBalance) {
        long balance = initialBalance;
        if (events == null) {
            return initialBalance;
        }
        for (String event : events) {
            if (event == null || event.isBlank()) {
                continue;
            }
            String[] parts = event.trim().split("\\s+");
            if (parts.length != 2) {
                throw new IllegalArgumentException("malformed event: " + event);
            }
            long amount;
            try {
                amount = Long.parseLong(parts[1]);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("malformed event: " + event);
            }
            if (amount < 0) {
                throw new IllegalArgumentException("malformed event: " + event);
            }
            if (parts[0].equalsIgnoreCase("CREDIT")) {
                balance += amount;
            } else if (parts[0].equalsIgnoreCase("DEBIT")) {
                if (balance - amount < 0) {
                    throw new IllegalStateException("balance cannot go negative");
                }
                balance -= amount;
            } else {
                throw new IllegalArgumentException("malformed event: " + event);
            }
        }
        return (int) balance;
    }
}
