import java.util.List;

public class Main {
    public static String resolve(List<String> paths) {
        if (paths == null || paths.isEmpty()) {
            return "";
        }
        String winner = null;
        int winnerDepth = Integer.MAX_VALUE;
        for (String path : paths) {
            String[] coordinates = split(path);
            if (coordinates.length < winnerDepth) {
                winnerDepth = coordinates.length;
                winner = versionOf(coordinates[coordinates.length - 1]);
            }
        }
        return winner;
    }

    private static String[] split(String path) {
        if (path == null || path.isBlank()) {
            throw new IllegalArgumentException("path must not be blank");
        }
        String[] coordinates = path.trim().split("->", -1);
        for (String coordinate : coordinates) {
            versionOf(coordinate);
        }
        return coordinates;
    }

    private static String versionOf(String coordinate) {
        String trimmed = coordinate == null ? "" : coordinate.trim();
        String[] parts = trimmed.split(":", -1);
        if (parts.length != 3 || parts[0].isBlank() || parts[1].isBlank() || parts[2].isBlank()) {
            throw new IllegalArgumentException("coordinate must be groupId:artifactId:version: " + coordinate);
        }
        return parts[2].trim();
    }
}
