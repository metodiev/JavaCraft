import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

public class Main {
    public static Optional<String> field(String json, String path) {
        if (json == null || path == null || path.isEmpty()) {
            return Optional.empty();
        }
        Object root;
        try {
            Parser parser = new Parser(json);
            root = parser.parseValue();
            parser.skipWhitespace();
            if (!parser.atEnd()) {
                return Optional.empty();
            }
        } catch (RuntimeException malformed) {
            return Optional.empty();
        }
        Object current = root;
        for (String segment : path.split("\\.", -1)) {
            if (segment.isEmpty() || !(current instanceof Map<?, ?> object)) {
                return Optional.empty();
            }
            current = object.get(segment);
        }
        return current instanceof String value ? Optional.of(value) : Optional.empty();
    }

    private static final class Parser {
        private final String text;
        private int pos;

        Parser(String text) {
            this.text = text;
        }

        boolean atEnd() {
            return pos >= text.length();
        }

        void skipWhitespace() {
            while (pos < text.length() && Character.isWhitespace(text.charAt(pos))) {
                pos++;
            }
        }

        Object parseValue() {
            skipWhitespace();
            if (atEnd()) {
                throw new IllegalArgumentException("unexpected end of input");
            }
            char c = text.charAt(pos);
            return switch (c) {
                case '{' -> parseObject();
                case '[' -> parseArray();
                case '"' -> parseString();
                case 't' -> literal("true", Boolean.TRUE);
                case 'f' -> literal("false", Boolean.FALSE);
                case 'n' -> literal("null", null);
                default -> parseNumber();
            };
        }

        private Map<String, Object> parseObject() {
            Map<String, Object> object = new LinkedHashMap<>();
            pos++;
            skipWhitespace();
            if (!atEnd() && text.charAt(pos) == '}') {
                pos++;
                return object;
            }
            while (true) {
                skipWhitespace();
                String key = parseString();
                skipWhitespace();
                expect(':');
                object.put(key, parseValue());
                skipWhitespace();
                char c = next();
                if (c == '}') {
                    return object;
                }
                if (c != ',') {
                    throw new IllegalArgumentException("expected , or }");
                }
            }
        }

        private java.util.List<Object> parseArray() {
            java.util.List<Object> array = new java.util.ArrayList<>();
            pos++;
            skipWhitespace();
            if (!atEnd() && text.charAt(pos) == ']') {
                pos++;
                return array;
            }
            while (true) {
                array.add(parseValue());
                skipWhitespace();
                char c = next();
                if (c == ']') {
                    return array;
                }
                if (c != ',') {
                    throw new IllegalArgumentException("expected , or ]");
                }
            }
        }

        private String parseString() {
            expect('"');
            StringBuilder value = new StringBuilder();
            while (true) {
                char c = next();
                if (c == '"') {
                    return value.toString();
                }
                if (c != '\\') {
                    value.append(c);
                    continue;
                }
                char escape = next();
                switch (escape) {
                    case '"' -> value.append('"');
                    case '\\' -> value.append('\\');
                    case '/' -> value.append('/');
                    case 'b' -> value.append('\b');
                    case 'f' -> value.append('\f');
                    case 'n' -> value.append('\n');
                    case 'r' -> value.append('\r');
                    case 't' -> value.append('\t');
                    case 'u' -> {
                        if (pos + 4 > text.length()) {
                            throw new IllegalArgumentException("bad unicode escape");
                        }
                        value.append((char) Integer.parseInt(text.substring(pos, pos + 4), 16));
                        pos += 4;
                    }
                    default -> throw new IllegalArgumentException("bad escape");
                }
            }
        }

        private Object parseNumber() {
            int start = pos;
            while (pos < text.length() && "+-0123456789.eE".indexOf(text.charAt(pos)) >= 0) {
                pos++;
            }
            if (pos == start) {
                throw new IllegalArgumentException("not a value");
            }
            return Double.valueOf(text.substring(start, pos));
        }

        private Object literal(String token, Object value) {
            if (!text.startsWith(token, pos)) {
                throw new IllegalArgumentException("bad literal");
            }
            pos += token.length();
            return value;
        }

        private void expect(char expected) {
            if (next() != expected) {
                throw new IllegalArgumentException("expected " + expected);
            }
        }

        private char next() {
            if (atEnd()) {
                throw new IllegalArgumentException("unexpected end of input");
            }
            return text.charAt(pos++);
        }
    }
}
