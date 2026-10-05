import java.util.Locale;

public class Main {
    public record Money(long cents, String currency) {
        public Money {
            currency = currency == null ? "" : currency.toUpperCase(Locale.ROOT);
        }

        public boolean sameValue(Money other) {
            return other != null && cents == other.cents && currency.equals(other.currency);
        }
    }
}
