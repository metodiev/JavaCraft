import java.util.List;

public class Main {
    public static final class ServerConfig {
        private final String host;
        private final int port;
        private final List<String> tags;

        private ServerConfig(Builder builder) {
            this.host = builder.host;
            this.port = builder.port;
            this.tags = builder.tags;
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

        // TODO: reject a missing host, a non-positive port and a missing port, and keep a defensive copy of the tags
        public static final class Builder {
            private String host;
            private int port;
            private List<String> tags = List.of();

            public Builder host(String host) {
                this.host = host;
                return this;
            }

            public Builder port(int port) {
                this.port = port;
                return this;
            }

            public Builder tag(String tag) {
                this.tags = List.of(tag);
                return this;
            }

            public ServerConfig build() {
                return new ServerConfig(this);
            }
        }
    }
}
