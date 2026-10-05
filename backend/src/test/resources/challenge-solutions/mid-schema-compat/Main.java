import java.util.List;

public class Main {
    public static String compatibility(List<String> removedFields, List<String> addedOptional, List<String> addedRequired) {
        boolean backwardBroken = addedRequired != null && !addedRequired.isEmpty();
        boolean forwardBroken = removedFields != null && !removedFields.isEmpty();
        if (backwardBroken && forwardBroken) {
            return "NONE";
        }
        if (backwardBroken) {
            return "FORWARD";
        }
        if (forwardBroken) {
            return "BACKWARD";
        }
        return "FULL";
    }
}
