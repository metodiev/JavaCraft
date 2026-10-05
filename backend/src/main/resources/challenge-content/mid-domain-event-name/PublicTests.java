import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("an event is the aggregate plus its past tense action", () ->
                Main.eventName("order", "place").equals("OrderPlaced"));
        t.put("an action already in the past tense is kept", () ->
                Main.eventName("order", "placed").equals("OrderPlaced")
                        && Main.eventName("order", "CONFIRMED").equals("OrderConfirmed"));
        t.put("multi word parts become PascalCase", () ->
                Main.eventName("order_item", "cancel").equals("OrderItemCanceled")
                        && Main.eventName("order item", "cancel").equals("OrderItemCanceled"));
        t.put("an e ending takes a d and a consonant y becomes ied", () ->
                Main.eventName("invoice", "approve").equals("InvoiceApproved")
                        && Main.eventName("invoice", "apply").equals("InvoiceApplied"));
        t.put("null or blank parts contribute nothing", () ->
                Main.eventName(null, "place").equals("Placed")
                        && Main.eventName("order", null).equals("Order")
                        && Main.eventName("order", "  ").equals("Order"));
        t.put("both parts missing yields an empty name", () ->
                Main.eventName(null, null).isEmpty() && Main.eventName("  ", "").isEmpty());
        t.put("case is normalised", () ->
                Main.eventName("ORDER", "PLACE").equals("OrderPlaced")
                        && Main.eventName("Total_Amount", "PLACE").equals("TotalAmountPlaced"));
        return t;
    }
}
