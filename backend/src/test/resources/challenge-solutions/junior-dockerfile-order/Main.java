import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    public static List<String> optimise(List<String> instructions) {
        if (instructions == null) {
            return List.of();
        }
        int firstCopy = -1;
        for (int i = 0; i < instructions.size(); i++) {
            if (firstCopy < 0 && isSourceCopy(instructions.get(i))) {
                firstCopy = i;
            }
        }
        if (firstCopy < 0) {
            return new ArrayList<>(instructions);
        }
        List<String> moved = new ArrayList<>();
        for (int i = firstCopy + 1; i < instructions.size(); i++) {
            String instruction = instructions.get(i);
            if (isDependency(instruction)) {
                moved.add(instruction);
            }
        }
        if (moved.isEmpty()) {
            return new ArrayList<>(instructions);
        }
        List<String> result = new ArrayList<>(instructions.size());
        for (int i = 0; i < instructions.size(); i++) {
            String instruction = instructions.get(i);
            if (i == firstCopy) {
                result.addAll(moved);
            }
            if (isDependency(instruction) && i > firstCopy) {
                continue;
            }
            result.add(instruction);
        }
        return result;
    }

    private static boolean isDependency(String instruction) {
        if (instruction == null) {
            return false;
        }
        String text = instruction.trim().toUpperCase(Locale.ROOT);
        return text.startsWith("RUN")
                && (text.contains("DEPENDENC") || text.contains("GO-OFFLINE"));
    }

    private static boolean isSourceCopy(String instruction) {
        if (instruction == null) {
            return false;
        }
        String text = instruction.trim();
        String upper = text.toUpperCase(Locale.ROOT);
        if (!upper.startsWith("COPY ") && !upper.startsWith("ADD ")) {
            return false;
        }
        String[] parts = text.split("\\s+");
        int index = 1;
        while (index < parts.length && parts[index].startsWith("--")) {
            index++;
        }
        if (index >= parts.length) {
            return false;
        }
        String source = parts[index].toLowerCase(Locale.ROOT);
        return source.equals(".") || source.equals("./") || source.equals("src") || source.startsWith("src/");
    }
}
