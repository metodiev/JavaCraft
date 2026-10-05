public class Main {
    public static String selectKey(int keyVersion, int activeVersion, int retainVersions) {
        if (keyVersion < 1 || activeVersion < 1) {
            throw new IllegalArgumentException("key versions start at 1");
        }
        if (retainVersions < 1) {
            throw new IllegalArgumentException("at least one version must be retained");
        }
        if (keyVersion > activeVersion) {
            throw new IllegalArgumentException("key version is ahead of the active version");
        }
        if (keyVersion == activeVersion) {
            return "encrypt and decrypt";
        }
        if (keyVersion >= activeVersion - retainVersions) {
            return "decrypt only";
        }
        return "retired";
    }
}
