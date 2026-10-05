import java.util.ArrayList;
import java.util.List;

public class Main {
    public static final class ServerConfig {
        private final String host;
        private final int port;
        private final List<String> tags;

        private ServerConfig(Builder builder) {
            this.host = builder.host;
            this.port = builder.port;
            this.tags = List.copyOf(builder.tags);
        }

        public String host() {
            return host;
        }

        public int port() {
            return port;
        }

        public List<String> tags() {
            return tags;
        }

        public static Builder builder() {
            return new Builder();
        }

        public static final class Builder {
            private String host;
            private int port;
            private final List<String> tags = new ArrayList<>();

            public Builder host(String host) {
                this.host = host;
                return this;
            }

            public Builder port(int port) {
                this.port = port;
                return this;
            }

            public Builder tag(String tag) {
                this.tags.add(tag);
                return this;
            }

            public ServerConfig build() {
                if (host == null || host.isBlank()) {
                    throw new IllegalStateException("host is required");
                }
                if (port <= 0) {
                    throw new IllegalStateException("port must be positive");
                }
                return new ServerConfig(this);
            }
        }
    }
}
