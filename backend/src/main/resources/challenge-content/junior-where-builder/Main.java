import java.util.List;

public class Main {
    public static final List<String> ALLOWED_COLUMNS = List.of("id", "email", "status", "created_at");
    public static final List<String> ALLOWED_OPERATORS = List.of("=", "<>", "<", "<=", ">", ">=");

    public static String whereFor(String column, String operator, int parameterIndex) {
        // TODO: reject anything that is not allowlisted and bind the value as a placeholder
        return column + " " + operator + " " + parameterIndex;
    }
}
