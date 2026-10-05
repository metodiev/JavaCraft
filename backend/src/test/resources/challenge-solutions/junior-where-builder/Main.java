import java.util.List;

public class Main {
    public static final List<String> ALLOWED_COLUMNS = List.of("id", "email", "status", "created_at");
    public static final List<String> ALLOWED_OPERATORS = List.of("=", "<>", "<", "<=", ">", ">=");

    public static String whereFor(String column, String operator, int parameterIndex) {
        if (column == null || operator == null || !ALLOWED_COLUMNS.contains(column) || !ALLOWED_OPERATORS.contains(operator)
                || parameterIndex < 1) {
            throw new IllegalArgumentException("invalid where fragment");
        }
        return column + " " + operator + " ?";
    }
}
