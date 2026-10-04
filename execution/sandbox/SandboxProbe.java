import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.NetworkInterface;
import java.net.Socket;
import java.nio.file.AccessDeniedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Enumeration;

public final class SandboxProbe {
    private SandboxProbe() {}

    public static void main(String[] args) throws Exception {
        long uid = ((Number) Files.getAttribute(Path.of("/proc/self"), "unix:uid")).longValue();
        require(uid == 10001, "unexpected sandbox user");
        require(!Files.isWritable(Path.of("/etc/passwd")), "image filesystem is writable");
        require(!Files.isWritable(Path.of("/opt/sandbox/classes")), "sandbox image is writable");

        Path workspaceFile = Path.of("/workspace/probe");
        Files.writeString(workspaceFile, "ok");
        Files.delete(workspaceFile);
        long workspaceSize = Files.getFileStore(Path.of("/workspace")).getTotalSpace();
        require(workspaceSize > 0 && workspaceSize <= 40L * 1024 * 1024, "workspace is not bounded tmpfs");

        Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
        boolean loopbackFound = false;
        while (interfaces != null && interfaces.hasMoreElements()) {
            NetworkInterface network = interfaces.nextElement();
            require(network.isLoopback(), "sandbox has a non-loopback network interface");
            loopbackFound = true;
        }
        require(loopbackFound, "loopback interface is missing");

        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress("192.0.2.1", 80), 300);
            throw new IllegalStateException("sandbox reached an external network address");
        } catch (IOException expected) {
            // A failed connection is the expected result with an isolated network namespace.
        }
        try {
            Files.writeString(Path.of("/.javacraft-write-probe"), "unexpected");
            Files.delete(Path.of("/.javacraft-write-probe"));
            throw new IllegalStateException("sandbox root filesystem is writable");
        } catch (AccessDeniedException expected) {
            // The root filesystem must remain read-only.
        }

        System.out.println("SANDBOX_PROBE_OK");
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new IllegalStateException(message);
        }
    }
}
