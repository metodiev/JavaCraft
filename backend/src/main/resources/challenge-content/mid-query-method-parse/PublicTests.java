import java.util.*;
import java.util.concurrent.Callable;

public class PublicTests {
    public static Map<String, Callable<Boolean>> tests() {
        Map<String, Callable<Boolean>> t = new LinkedHashMap<>();
        t.put("a single property is an equals predicate",
                () -> Main.describe("findByLastname").equals("lastname EQUALS"));
        t.put("and joins criteria in declaration order",
                () -> Main.describe("findByLastnameAndFirstnameGreaterThan")
                        .equals("lastname EQUALS AND firstname GREATER_THAN"));
        t.put("or joins criteria with the or keyword",
                () -> Main.describe("findByStatusOrPriority").equals("status EQUALS OR priority EQUALS"));
        t.put("each keyword suffix maps to its operator", () -> Main.describe("readByAgeGreaterThanEqual")
                .equals("age GREATER_THAN_EQUAL")
                && Main.describe("getByTitleContaining").equals("title CONTAINING")
                && Main.describe("queryByEmailLike").equals("email LIKE")
                && Main.describe("searchByCodeStartingWith").equals("code STARTING_WITH"));
        t.put("only the first letter of a property is lower cased",
                () -> Main.describe("findByFirstName").equals("firstName EQUALS"));
        t.put("nullness keywords are recognised",
                () -> Main.describe("findByDeletedAtIsNullAndNameIsNotNull")
                        .equals("deletedAt IS_NULL AND name IS_NOT_NULL"));
        t.put("malformed names are rejected", () -> rejects("selectAllUsers") && rejects("")
                && rejects(null) && rejects("findByOrderAnd") && rejects("findByAndName")
                && rejects("findByGreaterThan"));
        return t;
    }

    private static boolean rejects(String methodName) {
        try {
            Main.describe(methodName);
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }
}
