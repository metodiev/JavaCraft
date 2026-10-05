import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an additive column is not a blocker", () -> Main.blockers(
                List.of("ALTER TABLE orders ADD COLUMN note text")).isEmpty());
        t.put("creating a table and an index is not a blocker", () -> Main.blockers(
                List.of("CREATE TABLE audit (id bigint)", "CREATE INDEX audit_idx ON audit (id)")).isEmpty());
        t.put("dropping a column is a blocker", () -> Main.blockers(
                List.of("ALTER TABLE orders DROP COLUMN legacy_code"))
                .equals(List.of("ALTER TABLE orders DROP COLUMN legacy_code")));
        t.put("truncating a table is a blocker", () -> Main.blockers(
                List.of("TRUNCATE TABLE orders")).equals(List.of("TRUNCATE TABLE orders")));
        t.put("renaming a column is a blocker", () -> Main.blockers(
                List.of("ALTER TABLE orders RENAME COLUMN a TO b"))
                .equals(List.of("ALTER TABLE orders RENAME COLUMN a TO b")));
        t.put("destructive keywords are matched case insensitively", () -> Main.blockers(
                List.of("alter table orders drop column a")).size() == 1);
        t.put("only blockers are returned in input order", () -> Main.blockers(List.of(
                "ALTER TABLE orders ADD COLUMN note text",
                "TRUNCATE TABLE audit",
                "DROP TABLE sessions")).equals(List.of("TRUNCATE TABLE audit", "DROP TABLE sessions")));
        t.put("null statements and a null list are skipped", () -> Main.blockers(
                Arrays.asList(null, "  ", "DROP INDEX orders_idx"))
                .equals(List.of("DROP INDEX orders_idx")) && Main.blockers(null).isEmpty());
        return t;
    }
}
