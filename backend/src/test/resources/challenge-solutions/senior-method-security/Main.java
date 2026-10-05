import java.util.Set;

public class Main {
    private String text;
    private int pos;
    private Set<String> authorities;
    private String ownerId;
    private String callerId;

    public static boolean permit(String expression, Set<String> authorities, String ownerId, String callerId) {
        if (expression == null || expression.isBlank()) {
            return false;
        }
        Main parser = new Main();
        parser.text = expression;
        parser.authorities = authorities;
        parser.ownerId = ownerId;
        parser.callerId = callerId;
        try {
            boolean result = parser.parseOr();
            parser.skipSpaces();
            return parser.pos == parser.text.length() && result;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private boolean parseOr() {
        boolean value = parseAnd();
        while (true) {
            skipSpaces();
            if (consume("||") || consumeWord("or")) {
                boolean right = parseAnd();
                value = value || right;
            } else {
                return value;
            }
        }
    }

    private boolean parseAnd() {
        boolean value = parseUnary();
        while (true) {
            skipSpaces();
            if (consume("&&") || consumeWord("and")) {
                boolean right = parseUnary();
                value = value && right;
            } else {
                return value;
            }
        }
    }

    private boolean parseUnary() {
        skipSpaces();
        if (consume("!")) {
            return !parseUnary();
        }
        if (consumeWord("not")) {
            return !parseUnary();
        }
        return parseAtom();
    }

    private boolean parseAtom() {
        skipSpaces();
        if (consume("(")) {
            boolean value = parseOr();
            if (!consume(")")) {
                throw new IllegalArgumentException("missing )");
            }
            return value;
        }
        if (consumeWord("isOwner")) {
            return ownerId != null && !ownerId.isBlank() && ownerId.equals(callerId);
        }
        if (consumeWord("hasRole")) {
            return hasAuthority("ROLE_" + argument());
        }
        if (consumeWord("hasAuthority")) {
            return hasAuthority(argument());
        }
        throw new IllegalArgumentException("unknown atom at " + pos);
    }

    private boolean hasAuthority(String authority) {
        return authorities != null && authorities.contains(authority);
    }

    private String argument() {
        skipSpaces();
        if (!consume("(")) {
            throw new IllegalArgumentException("missing (");
        }
        skipSpaces();
        if (!consume("'")) {
            throw new IllegalArgumentException("missing quote");
        }
        int end = text.indexOf('\'', pos);
        if (end < 0) {
            throw new IllegalArgumentException("unterminated literal");
        }
        String value = text.substring(pos, end);
        pos = end + 1;
        skipSpaces();
        if (!consume(")")) {
            throw new IllegalArgumentException("missing )");
        }
        return value;
    }

    private boolean consume(String token) {
        if (text.startsWith(token, pos)) {
            pos += token.length();
            return true;
        }
        return false;
    }

    private boolean consumeWord(String word) {
        if (!text.regionMatches(true, pos, word, 0, word.length())) {
            return false;
        }
        int after = pos + word.length();
        boolean leftOk = pos == 0 || !Character.isLetterOrDigit(text.charAt(pos - 1));
        boolean rightOk = after >= text.length() || !Character.isLetterOrDigit(text.charAt(after));
        if (leftOk && rightOk) {
            pos = after;
            return true;
        }
        return false;
    }

    private void skipSpaces() {
        while (pos < text.length() && Character.isWhitespace(text.charAt(pos))) {
            pos++;
        }
    }
}
