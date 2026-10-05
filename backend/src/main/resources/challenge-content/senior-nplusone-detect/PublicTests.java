import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a statement repeated once per parent row is flagged", () -> Main.offenders(List.of(
                "select * from orders where status = 'NEW'",
                "select * from customer where id = 1",
                "select * from customer where id = 2",
                "select * from customer where id = 3"))
                .equals(List.of("select * from customer where id = ?")));
        t.put("a single parent statement is not flagged", () -> Main.offenders(List.of(
                "select * from orders where status = 'NEW'",
                "select * from customer where id = 1")).isEmpty());
        t.put("numbers are normalised and whitespace collapsed", () -> Main.offenders(List.of(
                "select  *  from orders",
                "select * from item where id=10",
                "select * from item   where   id=11"))
                .equals(List.of("select * from item where id=?")));
        t.put("grouping is case-sensitive",
                () -> Main.offenders(List.of(
                        "select * from orders",
                        "select * from item where id = 1",
                        "select * from ITEM where id = 2")).isEmpty());
        t.put("a statement below the parent count is not flagged", () -> Main.offenders(List.of(
                "select * from orders",
                "select * from orders",
                "select * from orders",
                "select * from customer where id = 1",
                "select * from customer where id = 2")).isEmpty());
        t.put("child statements matching the parent count are flagged", () -> Main.offenders(List.of(
                "select * from orders",
                "select * from orders",
                "select * from item where oid = 1",
                "select * from item where oid = 2")).equals(List.of("select * from item where oid = ?")));
        t.put("several offenders are returned sorted and de-duplicated", () -> Main.offenders(List.of(
                "select * from orders",
                "select * from b where id = 1",
                "select * from b where id = 2",
                "select * from a where id = 1",
                "select * from a where id = 2",
                "select * from a where id = 3"))
                .equals(List.of("select * from a where id = ?", "select * from b where id = ?")));
        t.put("null, empty or single-statement logs report nothing", () -> Main.offenders(null).isEmpty()
                && Main.offenders(List.of()).isEmpty()
                && Main.offenders(List.of("select * from orders")).isEmpty());
        t.put("blank lines are ignored", () -> Main.offenders(Arrays.asList(
                "select * from orders", "   ", null,
                "select * from item where id = 1", "select * from item where id = 2"))
                .equals(List.of("select * from item where id = ?")));
        return t;
    }
}
