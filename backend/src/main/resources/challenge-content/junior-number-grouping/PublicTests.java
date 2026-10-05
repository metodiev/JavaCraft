import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("keeps small numbers unchanged", () -> Main.groupDigits(999).equals("999") && Main.groupDigits(0).equals("0"));
        t.put("groups exactly four digits", () -> Main.groupDigits(1000).equals("1,000"));
        t.put("groups exactly five digits", () -> Main.groupDigits(10000).equals("10,000"));
        t.put("groups millions", () -> Main.groupDigits(1234567).equals("1,234,567"));
        t.put("keeps the minus sign for negatives", () -> Main.groupDigits(-1234567).equals("-1,234,567"));
        t.put("formats Long.MAX_VALUE", () -> Main.groupDigits(Long.MAX_VALUE).equals("9,223,372,036,854,775,807"));
        t.put("formats Long.MIN_VALUE without overflow", () -> Main.groupDigits(Long.MIN_VALUE).equals("-9,223,372,036,854,775,808"));
        return t;
    }
}
