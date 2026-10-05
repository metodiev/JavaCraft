public class Main {
    public record Money(long cents, String currency) {
        // TODO: normalise the currency to upper case in a compact constructor,
        // treating a null currency as an empty string
        public Money {
        }

        public boolean sameValue(Money other) {
            // TODO: compare cents and the normalised currency, returning false for null
            return false;
        }
    }
}
