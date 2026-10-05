-- V24 — HTTP and networking deep dive.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('http-methods-semantics', 'HTTP Methods and Their Semantics', 'Understand safety, idempotency, and method choice before designing any endpoint.', 'Junior', 22, true, 1),
    ('http-status-code-craft', 'Crafting Precise HTTP Status Codes', 'Pick 2xx, 4xx, and 5xx codes deliberately instead of collapsing every outcome into 200.', 'Junior', 24, true, 1),
    ('http-headers-that-matter', 'HTTP Headers That Matter', 'Handle content negotiation, validators, conditional requests, and redirect hints correctly.', 'Junior', 24, true, 1),
    ('http-caching-in-depth', 'HTTP Caching in Depth', 'Separate freshness from validation and design cache keys that never leak across users.', 'Mid', 34, true, 1),
    ('http-2-and-http-3', 'HTTP/2 and HTTP/3 in Practice', 'Reason about multiplexing, head-of-line blocking, and QUIC when designing APIs.', 'Senior', 40, true, 1),
    ('tls-handshake-essentials', 'TLS Handshake Essentials', 'Trace the TLS handshake, trust chains, and SNI to diagnose negotiation failures fast.', 'Senior', 38, true, 1),
    ('connection-reuse-and-pooling', 'Connection Reuse and Pooling', 'Size pools per host, honor keep-alive, and evict idle connections before the server does.', 'Mid', 32, true, 1),
    ('timeouts-and-retry-matrix', 'Timeouts and the Retry Matrix', 'Bound every network call with the right timeout and retry only what is safe to repeat.', 'Mid', 34, true, 1),
    ('proxies-and-load-balancers', 'Proxies and Load Balancers', 'Understand forwarding layers, client identity headers, stickiness, and health checks.', 'Mid', 32, true, 1),
    ('dns-in-service-calls', 'DNS in Service Calls', 'Account for resolution order, TTLs, and JVM caching when DNS drives failover.', 'Mid', 28, true, 1),
    ('compression-and-payload-strategies', 'Compression and Payload Strategies', 'Compress the right layers and keep payloads small enough to stay fast under load.', 'Junior', 20, true, 1),
    ('websockets-and-sse', 'WebSockets and Server-Sent Events', 'Choose sockets, server-sent events, or polling, and plan reconnects and scaling.', 'Senior', 38, true, 1),
    ('content-security-and-cors', 'CORS and Content Security', 'Apply same-origin rules, preflight behavior, and credential rules without breaking clients.', 'Mid', 32, true, 1),
    ('cookie-and-session-mechanics', 'Cookie and Session Mechanics', 'Scope cookies correctly and rotate sessions so authentication stays trustworthy.', 'Mid', 30, true, 1),
    ('network-debugging-toolkit', 'The Network Debugging Toolkit', 'Correlate client and server evidence with curl, packet capture, and handshake inspection.', 'Junior', 26, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('http-methods-semantics', 1, 'Safety and idempotency defined', $body$Safe methods (GET, HEAD, OPTIONS, TRACE) promise no intended state change; idempotent methods (the safe ones plus PUT and DELETE) promise that repeating an identical request has the same intended effect as one request. Those are contracts about intended effect, not about response codes. Clients, proxies, and retry libraries rely on them: a browser or gateway may prefetch a GET or retry a PUT on a dropped connection without asking you. Rule of thumb: if repeating a request could charge a card twice or append a second record, the operation is not idempotent and must not use a safe or idempotent method.$body$, $code$GET /orders/42 HTTP/1.1
Host: api.example.com

PUT /orders/42/status HTTP/1.1
Host: api.example.com
Content-Type: application/json

{"status":"shipped"}$code$),
    ('http-methods-semantics', 2, 'PUT replaces, PATCH adjusts', $body$PUT replaces the state of the target resource with the enclosed representation, so the client sends the full new state and the server treats the target as created or replaced. PATCH applies a change to the resource and depends on a patch format, which makes it neither safe nor automatically idempotent. POST submits data to be processed, commonly creating a subordinate resource whose identifier the server chooses. Rule of thumb: use PUT for full replacement at a client-known URI, PATCH for partial updates, and POST when the server owns the new identifier or the operation is neither safe nor idempotent.$body$, $code$PUT /accounts/8842 HTTP/1.1
Content-Type: application/json

{"name":"Ada","currency":"EUR","active":true}

PATCH /accounts/8842 HTTP/1.1
Content-Type: application/merge-patch+json

{"active":false}$code$),
    ('http-methods-semantics', 3, 'Methods in real APIs', $body$Real APIs drift from the textbook. Some services tunnel everything through POST so that gateways, CORS, or tooling accept it, but that discards retry and caching semantics that clients and intermediaries already implement. Others use GET for state changes, which lets browsers and proxies repeat them. Choose methods by semantics first, then adapt infrastructure. Return 405 with an Allow header for unsupported methods and 404 for unknown targets. Rule of thumb: keep transport semantics honest; if an operation does not fit a standard method, model it as a named operation resource rather than abusing GET.$body$, $code$POST /orders/42/cancel HTTP/1.1
Host: api.example.com

HTTP/1.1 202 Accepted
Location: /operations/9917

PATCH /orders HTTP/1.1
Host: api.example.com

HTTP/1.1 405 Method Not Allowed
Allow: GET, POST$code$),
    ('http-status-code-craft', 1, 'Codes are the protocol contract', $body$A status code tells clients, proxies, and retry libraries whether a request succeeded, failed on the client side, or failed on the server side. A 2xx means the request was understood and accepted; a 4xx means the same request should not succeed unchanged; a 5xx means the server failed while the request itself may have been valid. That classification drives retries, alerting, and caching across every generic tool in the path. Returning 200 with an error object in the body hides failures from all of them. Rule of thumb: choose the most specific code whose definition matches, and never encode failure as 200.$body$, $code$HTTP/1.1 201 Created
Location: /orders/1041

HTTP/1.1 422 Unprocessable Content
Content-Type: application/problem+json

{"title":"Shipping address is outside the service region."}$code$),
    ('http-status-code-craft', 2, 'Choosing between 401, 403, 409, 422', $body$A 401 means the request lacks valid authentication credentials and must carry a WWW-Authenticate challenge; a 403 means the server understood the request but refuses it, so repeating identical credentials will not help. For write conflicts, 409 signals a clash with current state, such as a version mismatch, while 422 signals syntactically valid content whose instructions are semantically wrong, such as a date range that ends before it starts. Distinguish 400 for malformed syntax, 415 for an unsupported media type, and 404 for an unknown target. Rule of thumb: map each failure class to exactly one code and document it.$body$, $code$HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="orders"

HTTP/1.1 403 Forbidden
Content-Type: application/problem+json

HTTP/1.1 409 Conflict
{"code":"version_conflict"}

HTTP/1.1 422 Unprocessable Content
{"code":"invalid_date_range"}$code$),
    ('http-status-code-craft', 3, 'Avoiding status code soup', $body$A service that invents codes, returns 200 for everything, or maps unrelated failures onto 400 forces clients to guess. Publish the small set of codes each endpoint can return, describe the error body schema once, and keep the mapping stable across releases. Reserve 5xx for genuine server faults, because monitoring and retry logic treat it that way; a validation failure returned as 500 will page an on-call engineer and may be retried. Rule of thumb: if a client cannot decide what to do from the code and the error body alone, the contract is incomplete.$body$, $code$HTTP/1.1 400 Bad Request
{"code":"malformed_json"}

HTTP/1.1 422 Unprocessable Content
{"code":"start_after_end"}

HTTP/1.1 503 Service Unavailable
Retry-After: 30$code$),
    ('http-headers-that-matter', 1, 'Content negotiation in practice', $body$Clients describe what they can accept through Accept, Accept-Language, and Accept-Encoding, and declare what they send with Content-Type. Servers pick a representation and report the choice in response headers such as Content-Type and Content-Language. Wildcards and quality values express preference order, and 406 reports that no acceptable representation exists. In practice, answering with a sensible default beats failing when a client sends an imprecise Accept header, but that choice must be recorded in Vary so caches key on it. Rule of thumb: negotiate only on axes that genuinely change bytes, and keep the representation set small.$body$, $code$GET /invoices/7781 HTTP/1.1
Accept: application/json, text/csv;q=0.8
Accept-Language: en, bg;q=0.7
Accept-Encoding: gzip

HTTP/1.1 200 OK
Content-Type: application/json
Content-Language: en
Vary: Accept, Accept-Language, Accept-Encoding$code$),
    ('http-headers-that-matter', 2, 'Validators and conditional requests', $body$An ETag identifies a specific representation. Clients replay it in If-None-Match, and the server answers 304 Not Modified with no body when the representation is unchanged, saving bandwidth. Last-Modified with If-Modified-Since does the same at one-second resolution. If-Match enables optimistic concurrency, and a mismatch yields 412 Precondition Failed. Cache-Control and Expires tell caches how long a response may be reused without asking the origin again. Rule of thumb: send validators on readable resources, and require If-Match for lost-update protection on writes.$body$, $code$GET /invoices/7781 HTTP/1.1
If-None-Match: "v7-3f9c"

HTTP/1.1 304 Not Modified
ETag: "v7-3f9c"
Cache-Control: max-age=60

PUT /invoices/7781 HTTP/1.1
If-Match: "v7-3f9c"

HTTP/1.1 412 Precondition Failed$code$),
    ('http-headers-that-matter', 3, 'Redirects and capacity headers', $body$Location points at a related resource: the target of a redirect, the newly created resource after 201, or a status endpoint after 202. Retry-After tells clients when to try again after 429 or 503, expressed as seconds or an HTTP date. Without it, clients pick their own backoff and may hammer an overloaded service. Related fields such as Accept-Ranges support large downloads. Rule of thumb: whenever you reject a request for capacity reasons, include Retry-After and keep the value honest.$body$, $code$HTTP/1.1 201 Created
Location: /invoices/7781

HTTP/1.1 202 Accepted
Location: /invoices/7781/status

HTTP/1.1 429 Too Many Requests
Retry-After: 12$code$),
    ('http-caching-in-depth', 1, 'Freshness versus validation', $body$A cache first decides whether a stored response is fresh, using max-age and Age, and reuses it without contacting the origin. When the response is stale, the cache can validate it with If-None-Match or If-Modified-Since; a 304 refreshes the stored entry while a 200 replaces it. The phases solve different problems: freshness avoids the round trip entirely, validation avoids resending a body. The directive no-cache does not mean do not store; it means the cache must validate before every reuse, which surprises teams that intended no-store. Rule of thumb: pick max-age for a bounded staleness budget, and add validators so stale entries refresh cheaply.$body$, $code$GET /articles/9 HTTP/1.1
If-None-Match: "article-9-v3"

HTTP/1.1 304 Not Modified
Cache-Control: max-age=120
Age: 45

HTTP/1.1 200 OK
Cache-Control: max-age=120
ETag: "article-9-v4"$code$),
    ('http-caching-in-depth', 2, 'Shared, private, and directive combinations', $body$private marks a response for one user and keeps shared caches such as CDNs and proxies from storing it; public allows storage where the default would not; s-maxage overrides max-age for shared caches only. stale-while-revalidate serves a stale response while refreshing in the background, and must-revalidate forbids serving stale entries after expiry. no-store applies to truly sensitive data. Incorrect combinations are common: public on an Authorization response, or private without validators on a personalized page. Rule of thumb: decide first whether a response is user-specific, then add shared-cache directives only to truly shareable representations.$body$, $code$HTTP/1.1 200 OK
Cache-Control: private, max-age=0, no-cache

HTTP/1.1 200 OK
Cache-Control: public, s-maxage=300

HTTP/1.1 200 OK
Cache-Control: no-store$code$),
    ('http-caching-in-depth', 3, 'Cache keys and the Vary header', $body$A cache stores responses under a key derived from the request method and URI, then splits entries by the header fields named in Vary. Forgetting Vary on a response that changes with Accept or Accept-Encoding lets a compressed body be served to a client that asked for identity encoding, or a language variant to the wrong reader. Overly broad Vary values, especially on volatile headers, destroy hit rates. Responses that differ by user must never land in a shared cache. Rule of thumb: name every negotiating request header in Vary, and audit personalized endpoints for private or no-store.$body$, $code$GET /articles/9 HTTP/1.1
Accept-Encoding: gzip, br
Accept-Language: en

HTTP/1.1 200 OK
Cache-Control: public, max-age=120
Vary: Accept-Encoding, Accept-Language
ETag: "article-9-v3"$code$),
    ('http-2-and-http-3', 1, 'Multiplexing on one connection', $body$HTTP/2 maps messages onto streams, so many concurrent exchanges share one TCP connection without the application-layer serialization that limited HTTP/1.1 pipelining. Header fields travel in a compressed binary frame format, cutting repeated metadata overhead. In practice clients open fewer connections, so per-connection flow-control windows and per-stream scheduling shape latency under load. Connection-specific fields such as Connection and Keep-Alive are forbidden, and intermediaries must strip them or peers treat the message as malformed. Rule of thumb: stop raising per-host connection counts as a scaling lever and tune stream concurrency and flow control instead.$body$, $code$HttpClient client = HttpClient.newBuilder()
        .version(HttpClient.Version.HTTP_2)
        .build();
HttpResponse<String> response = client.send(request,
        HttpResponse.BodyHandlers.ofString());
System.out.println(response.version()); // HTTP_2$code$),
    ('http-2-and-http-3', 2, 'Head-of-line blocking by layer', $body$HTTP/2 removes application-layer head-of-line blocking, but a lost TCP segment still stalls every stream on that connection, because TCP delivers bytes in order. HTTP/3 moves streams onto QUIC, a transport built on UDP with per-stream reliability, so one lost packet blocks only the stream that needed it. QUIC also combines transport and TLS handshakes and supports connection migration when a client network path changes. Latency-sensitive workloads benefit most; on clean, high-bandwidth links the difference is smaller. Rule of thumb: know whether observed latency comes from protocol structure or plain packet loss before rewriting clients.$body$, $code$curl --http2 -v https://api.example.com/orders

* ALPN: server accepted h2
* using HTTP/2
< HTTP/2 200
< content-type: application/json$code$),
    ('http-2-and-http-3', 3, 'What changes for API design', $body$Version-sensitive details leak into protocol behavior: HTTP/2 replaces the request line with pseudo-header fields such as :method and :path, and HTTP/3 drops transfer encoding entirely. Request priorities and server push exist in the standards but vary by stack and are often ignored or disabled, so never depend on them for correctness. Streaming APIs must handle flow control and cancellation explicitly. Rule of thumb: keep the API contract at the semantics layer, let the stack negotiate the protocol version, and test every version you actually serve.$body$, $code$HttpRequest request = HttpRequest.newBuilder(uri)
        .header("Accept", "application/json")
        .timeout(Duration.ofSeconds(3))
        .build();
HttpResponse<Void> response = client.send(request,
        HttpResponse.BodyHandlers.discarding());
System.out.println(response.version());$code$),
    ('tls-handshake-essentials', 1, 'The handshake round trip', $body$The client opens a TCP connection and sends ClientHello with supported versions, cipher suites, a key share, and the server name. The server replies with its chosen parameters and certificate chain, proves possession of the private key, and both sides derive session keys. TLS 1.3 completes this in one round trip, encrypts most of the handshake, and removed RSA key exchange and renegotiation in favor of forward-secret key agreement. Resumption through tickets or pre-shared keys avoids a full handshake, while early data trades replay protection for latency. Rule of thumb: budget one round trip for a fresh handshake and keep sessions resumable.$body$, $code$ClientHello
  supported_versions: TLS 1.3
  key_share, server_name: api.example.com
ServerHello
  selected TLS 1.3, certificate, finished
Application data (encrypted)$code$),
    ('tls-handshake-essentials', 2, 'Certificates and trust chains', $body$A server certificate binds a public key to names and is signed by an issuer. Clients verify the chain up to a locally trusted root, check validity dates, and match the requested host against subject alternative names. A missing intermediate commonly fails on strict clients even when browsers succeed, because browsers may fetch intermediates while a JVM trust store will not. Rotation requires overlapping validity so old and new chains are both trusted during rollout. Rule of thumb: serve the full chain except the root, and alert on expiry long before it happens.$body$, $code$openssl s_client -connect api.example.com:443 \
  -servername api.example.com -showcerts

Certificate chain
 0 s:CN = api.example.com
   i:C = US, O = Example CA, CN = Example Intermediate
 1 s:C = US, O = Example CA, CN = Example Intermediate$code$),
    ('tls-handshake-essentials', 3, 'SNI and common failure modes', $body$SNI carries the target host name inside ClientHello, letting one IP address serve many certificates. A client that omits SNI, or a proxy that strips it, receives the default certificate and then fails hostname verification. Other frequent failures are an untrusted issuer on an internal service, clock skew that breaks validity windows, and protocol mismatch when old clients meet a server that requires TLS 1.2 or newer. Inspect the handshake with openssl or JSSE debug output before guessing. Rule of thumb: reproduce with the same client stack that fails, not only with curl.$body$, $code$curl -v https://api.example.com/orders 2>&1 | grep -i "SSL certificate"

* SSL certificate problem: certificate has expired

openssl s_client -connect api.example.com:443 \
  -servername api.example.com

java -Djavax.net.debug=ssl:handshake -jar app.jar$code$),
    ('connection-reuse-and-pooling', 1, 'Keep-alive and connection lifetime', $body$Persistent connections let several request and response exchanges traverse one TCP connection, avoiding handshake and slow-start costs on every call. HTTP/1.1 keeps connections open by default unless a party sends Connection close. Servers close idle connections after their own keep-alive timeout, so a pooled connection can die while a client still considers it usable, and the next write fails with a reset. Well-behaved clients retry that idle-race failure once when the request is safe to repeat. Rule of thumb: set client idle eviction below the server idle timeout, and treat reuse failures as expected events.$body$, $code$GET /orders/42 HTTP/1.1
Host: api.example.com

HTTP/1.1 200 OK
Content-Length: 84

GET /orders/43 HTTP/1.1
Host: api.example.com

HTTP/1.1 200 OK$code$),
    ('connection-reuse-and-pooling', 2, 'Sizing pools per destination', $body$A pool needs a per-destination ceiling so one slow dependency cannot consume every connection, a total ceiling, and a defined wait policy when the pool is exhausted. Too small a pool queues requests behind connection acquisition; too large a pool creates bursts that overload the dependency and amplify retries. Size follows measured concurrency, and limits must account for every instance that calls the same target. Rule of thumb: start from concurrency per instance instead of a round number, and expose pool wait time as a metric.$body$, $code$PoolingHttpClientConnectionManager pool =
        new PoolingHttpClientConnectionManager();
pool.setMaxTotal(64);
pool.setDefaultMaxPerRoute(16);

CloseableHttpClient client = HttpClients.custom()
        .setConnectionManager(pool)
        .build();$code$),
    ('connection-reuse-and-pooling', 3, 'Reuse in Java HTTP clients', $body$The JDK HttpClient manages a pool per client instance, and pools are not shared between instances, so creating a client per call prevents reuse entirely. Build one client per destination class, reuse it, and set a connect timeout on the builder. Apache HttpClient pools are configured through a connection manager with per-route and total limits, plus validate-after-inactivity so stale sockets are discarded before use. In every client, a half-closed connection surfaces as an intermittent IOException on an otherwise healthy path. Rule of thumb: create long-lived clients and watch their occasional resets.$body$, $code$HttpClient client = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(2))
        .build();
for (String path : paths) {
    HttpRequest request = HttpRequest.newBuilder(
            URI.create(base + path)).build();
    client.send(request, HttpResponse.BodyHandlers.discarding());
}$code$),
    ('timeouts-and-retry-matrix', 1, 'Connect, read, and total deadlines', $body$Distinguish the connect timeout for establishing a connection, the read or response timeout for waiting on bytes, and the total request deadline that covers the whole call including retries. A missing read timeout lets a stuck socket block a worker indefinitely; a missing total deadline lets retries exceed the caller patience. Name resolution may sit outside the connect timeout depending on the client, so budget it explicitly. Deadlines should propagate through the call chain so nested calls stop together. Rule of thumb: give every remote call all applicable timeouts, with the total deadline as the smallest bound.$body$, $code$HttpClient client = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(2))
        .build();
HttpRequest request = HttpRequest.newBuilder(uri)
        .timeout(Duration.ofSeconds(5)) // whole exchange
        .build();$code$),
    ('timeouts-and-retry-matrix', 2, 'The retry safety matrix', $body$Retry only failures where the request may not have been processed or is safe to repeat: connect failures, timeouts before a response, 502 and 503, 504 from gateways, and 429 with Retry-After when the caller can wait. Never retry a request that may have applied side effects unless it is idempotent or protected by an idempotency key the server honors. Do not retry validation or authorization failures; repetition cannot change the outcome and adds load. Cap attempts, and count retries against a budget such as a small percentage of total requests.$body$, $code$// Retry only when repeating is safe:
// connect failures, timeouts before a response,
// 502, 503, 504, and 429 with Retry-After.
boolean retryable = switch (status) {
    case 502, 503, 504 -> true;
    case 429 -> retryAfter != null;
    default -> false;
};$code$),
    ('timeouts-and-retry-matrix', 3, 'Backoff, jitter, and budgets', $body$Exponential backoff with jitter spreads retries so many clients do not synchronize after a shared failure. Without jitter, a fleet retries in a thundering herd and turns a brief blip into an outage. Bound total attempts, stop when the deadline expires, and prefer server hints over fixed values when Retry-After is present. Retry budgets in the caller or in a mesh cap retry traffic as a fraction of normal requests, which keeps an overloaded dependency from being pushed further down. Rule of thumb: jitter every delay, budget every retry, and observe retries separately.$body$, $code$for (int attempt = 1; attempt <= 3; attempt++) {
    try {
        return send();
    } catch (HttpTimeoutException ex) {
        if (attempt == 3) throw ex;
        long delayMs = ThreadLocalRandom.current()
                .nextLong(baseMillis << (attempt - 1));
        Thread.sleep(delayMs);
    }
}$code$),
    ('proxies-and-load-balancers', 1, 'Forward and reverse proxies', $body$A forward proxy sits in front of clients and makes outbound requests on their behalf, commonly for egress control and inspection. A reverse proxy sits in front of servers, terminating TLS, routing by host or path, and buffering slow clients. Both change what the origin sees: the peer address belongs to the proxy, and hop-by-hop headers such as Connection and Transfer-Encoding apply to one hop only. Timeouts stack, so a long proxy read timeout can outlive a caller deadline and hold resources. Rule of thumb: draw the full request path when debugging, because every hop adds its own queues and limits.$body$, $code$GET /orders HTTP/1.1
Host: api.example.com

HTTP/1.1 200 OK
Content-Length: 1204
Connection: close$code$),
    ('proxies-and-load-balancers', 2, 'Client identity behind proxies', $body$Intermediaries record the original client in X-Forwarded-For and related headers, with RFC 7239 defining a standardized Forwarded field. Those values are client-controlled unless the edge overwrites them, so trusting the leftmost entry lets callers spoof rate limits and audit logs. Configure exactly one trusted edge to append, and have applications read the value injected there. Forwarded-Proto and Forwarded-Host are equally important for correct redirects and absolute links behind TLS termination. Rule of thumb: trust forwarded headers only from known proxy addresses, and scrub incoming ones at the edge.$body$, $code$GET /orders HTTP/1.1
Host: api.example.com
X-Forwarded-For: 203.0.113.7, 10.0.4.11
X-Forwarded-Proto: https
X-Forwarded-Host: api.example.com

HTTP/1.1 200 OK
Cache-Control: no-store$code$),
    ('proxies-and-load-balancers', 3, 'Stickiness and health checks', $body$Sticky sessions bind a client to one backend instance, which simplifies stateful protocols but complicates rolling deploys, autoscaling, and failure handling: when an instance dies, its clients lose their affinity. Prefer stateless services with externalized state, and use stickiness only for bounded migrations. Health checks should be shallow enough to answer quickly and deep enough to catch broken dependencies; a liveness probe that restarts on a slow database causes cascading failures, while a readiness probe that never fails routes traffic to dead instances. Rule of thumb: separate liveness from readiness and keep both honest.$body$, $code$GET /health/ready HTTP/1.1
Host: internal.example.com

HTTP/1.1 503 Service Unavailable
Retry-After: 5

GET /health/live HTTP/1.1

HTTP/1.1 200 OK$code$),
    ('dns-in-service-calls', 1, 'Resolution order and record TTLs', $body$Resolution walks configured sources, typically the hosts file, then DNS through system caches and resolvers, then the answer list order. Records carry a TTL that bounds how long resolvers may cache them, so DNS failover latency equals the record TTL plus caching added along the path, including negative caching for missing names. Weighted and health-aware records move traffic, but clients learn only after their cache expires. Rule of thumb: size TTLs as a deliberate trade-off between failover speed and query load, and never assume a change is visible immediately.$body$, $code$dig api.example.com A

;; ANSWER SECTION:
api.example.com. 60 IN A 203.0.113.20
api.example.com. 60 IN A 203.0.113.21
;; Query time: 24 msec$code$),
    ('dns-in-service-calls', 2, 'Caching inside the JVM', $body$The JVM caches resolved addresses independently of DNS TTLs. Positive results are governed by networkaddress.cache.ttl, whose default is implementation-specific and can greatly exceed the record TTL; negative results default to ten seconds. When a long-lived client resolves once, an endpoint change may not be picked up until it re-resolves, so failover can be slower than DNS configuration suggests. Aggressive positive caching is the classic cause of failover that takes hours. Rule of thumb: set a bounded positive TTL for dynamic endpoints and avoid manual host entries in production.$body$, $code$# Bound positive and negative JVM DNS caching.
networkaddress.cache.ttl=30
networkaddress.cache.negative.ttl=10

# Test override with a hosts file.
-Djdk.net.hosts.file=./test-hosts$code$),
    ('dns-in-service-calls', 3, 'Discovery and DNS overlap', $body$Service discovery layers such as Kubernetes DNS or SRV-based systems expose changing endpoints through DNS or a dedicated API. Overlap with DNS caching produces stale endpoint lists, connections to removed instances, and retry storms toward scaled-down replicas. Push-based discovery or frequent re-resolution avoids waiting on TTLs, and clients should reconnect rather than pin a dead address. Keep names stable and move endpoints; do not encode instance identity in the name. Rule of thumb: treat endpoint changes as normal traffic events and verify that your client stack actually re-resolves.$body$, $code$kubectl get endpoints orders

NAME     ENDPOINTS                      AGE
orders   10.0.4.11:8080,10.0.4.12:8080 3d

dig orders.default.svc.cluster.local
;; ANSWER SECTION:
orders.default.svc.cluster.local. 30 IN A 10.0.4.11
orders.default.svc.cluster.local. 30 IN A 10.0.4.12$code$),
    ('compression-and-payload-strategies', 1, 'Content-encoding trade-off choices', $body$Content-Encoding tells the client how a body was encoded after selection, typically gzip, deflate, or brotli. Compression shrinks text such as JSON and HTML dramatically but costs CPU on both sides: the server compresses every response and the client decompresses every read. Already-compressed payloads such as images, video, and archives gain little and can grow slightly. Compressing responses that mix secrets with attacker-controlled input enables the BREACH class of attacks, so disable compression or mask secrets on such pages. Rule of thumb: compress textual representations above a small threshold and skip formats that are already compressed.$body$, $code$GET /reports/2026-09 HTTP/1.1
Accept-Encoding: br, gzip

HTTP/1.1 200 OK
Content-Type: application/json
Content-Encoding: gzip
Vary: Accept-Encoding$code$),
    ('compression-and-payload-strategies', 2, 'Where compression should live', $body$Compression can happen in the application, in a reverse proxy, or at a CDN edge. Compressing once at the edge offloads application CPU and covers static and dynamic responses uniformly, but the application must stop compressing to avoid double encoding and must advertise the choice through Vary. Per-response compression inside the application is harder to keep consistent and easy to forget on a new endpoint. Caches key on Vary: Accept-Encoding, so omitting it mixes encoded and identity bodies. Rule of thumb: pick one layer to own compression, make it uniform, and document the threshold.$body$, $code$HTTP/1.1 200 OK
Content-Type: text/css
Content-Encoding: br
Cache-Control: public, max-age=31536000, immutable

HTTP/1.1 200 OK
Content-Type: image/png
Content-Length: 284117$code$),
    ('compression-and-payload-strategies', 3, 'Payload size discipline', $body$Every payload is parsed, copied, serialized, logged, and buffered somewhere, so unbounded documents become memory and latency problems. Cap request and response sizes, paginate or stream large collections, and avoid embedding unrelated data in one response. Repetitive field names cost bytes that compress well but still add parse time. For high-volume internal traffic, binary formats such as Protobuf reduce size and CPU at the cost of debuggability; JSON remains the default for external APIs. Rule of thumb: set explicit size limits at the edge and design each response for its smallest consumer.$body$, $code$GET /exports?limit=20000 HTTP/1.1
Accept-Encoding: gzip

HTTP/1.1 200 OK
Content-Type: application/json
Content-Encoding: gzip
Content-Length: 5124093$code$),
    ('websockets-and-sse', 1, 'Sockets, events, and polling', $body$WebSocket starts as an HTTP/1.1 upgrade and then switches to a framed full-duplex protocol on the same connection, which suits chat, collaborative editing, and command channels. Server-sent events keep a normal HTTP response open with a text/event-stream body, giving one-way delivery with event IDs and automatic reconnection. Both survive intermediaries only when idle timeouts and buffering are tuned; a proxy that buffers the body defeats SSE entirely. Rule of thumb: use sockets when the client must push, events when only the server pushes, and plain HTTP when updates are infrequent.$body$, $code$GET /events/prices HTTP/1.1
Accept: text/event-stream

HTTP/1.1 200 OK
Content-Type: text/event-stream
Cache-Control: no-store

id: 1041
event: price
data: {"symbol":"EURUSD","bid":1.0842}$code$),
    ('websockets-and-sse', 2, 'Reconnect and liveness strategy', $body$Long-lived connections drop: networks flap, load balancers recycle idle connections, and instances restart. Clients need exponential backoff with jitter, a resubscribe path, and event IDs or resume tokens so missed updates can be replayed. Heartbeats in both directions reveal half-open connections before the first real message fails. Without a reconnect design, every deployment triggers a synchronized reconnect storm that can flatten the fleet. Rule of thumb: treat disconnect as a normal state rather than an error, and make reconnection cheap for the server.$body$, $code$id: 1041
event: price
data: {"symbol":"EURUSD","bid":1.0842}

retry: 3000

: heartbeat$code$),
    ('websockets-and-sse', 3, 'Scaling long-lived connections', $body$Each open connection consumes a file descriptor, memory, and sometimes a thread, so long-lived connections constrain capacity and make rolling deploys disruptive. Fan-out requires shared state or a message broker so any instance can serve any subscriber, and backpressure must drop or coalesce slow consumers instead of buffering without limit. For updates every few seconds, conditional polling with ETags is simpler to operate. Rule of thumb: choose the cheapest mechanism that meets the latency requirement, and load-test connection count, not only request rate.$body$, $code$GET /ws HTTP/1.1
Host: api.example.com
Connection: Upgrade
Upgrade: websocket
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13

HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade$code$),
    ('content-security-and-cors', 1, 'How same-origin checks work', $body$A browser compares scheme, host, and port to decide whether two URLs share an origin. Cross-origin reads are blocked by default, but simple requests still reach the server: form-like POSTs and image or script loads can trigger state changes even when the response cannot be read. That asymmetry makes CORS a read control, not a write firewall, so state-changing endpoints need their own protections. Requests from server-side Java clients ignore CORS entirely. Rule of thumb: enforce authorization and CSRF defenses on the server and treat CORS as browser capability negotiation.$body$, $code$POST /orders HTTP/1.1
Host: api.example.com
Origin: https://evil.example.net

HTTP/1.1 201 Created
Access-Control-Allow-Origin: https://app.example.com$code$),
    ('content-security-and-cors', 2, 'Preflight and response headers', $body$For anything beyond a simple request, the browser sends an OPTIONS preflight naming the intended method and headers, and the server answers with Access-Control-Allow-Origin, Access-Control-Allow-Methods, and Access-Control-Allow-Headers. The real request follows only if the preflight allows it. Preflights add a round trip, so keep the allowed header list short and cache results with Access-Control-Max-Age. A missing or mismatched header produces an opaque browser error that reveals nothing about the server response. Rule of thumb: configure CORS at the edge or gateway so every service inherits one consistent policy.$body$, $code$OPTIONS /orders HTTP/1.1
Origin: https://app.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: content-type

HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST
Access-Control-Max-Age: 600$code$),
    ('content-security-and-cors', 3, 'Credentials and common mistakes', $body$Browsers send cookies or Authorization headers cross-origin only when the request opts in with credentials and the server answers with Access-Control-Allow-Credentials true plus one specific origin; the wildcard origin is invalid in that case. Reflecting any Origin header echoes attacker origins, and omitting Vary: Origin lets a shared cache serve one origin a policy meant for another. Allowing every origin together with credentials is equivalent to no protection. Rule of thumb: maintain an explicit allowlist of origins, echo only exact matches, and never combine wildcards with credentials.$body$, $code$HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Credentials: true
Vary: Origin

HTTP/1.1 200 OK
Access-Control-Allow-Origin: *$code$),
    ('cookie-and-session-mechanics', 1, 'Attributes that carry security', $body$Secure restricts a cookie to HTTPS, HttpOnly hides it from scripts, and SameSite says whether it travels on cross-site requests: Lax allows top-level navigations, Strict allows none, and None requires Secure and exposes the cookie cross-site. Cookies without Max-Age or Expires are session cookies removed when the browser closes. A new Set-Cookie can only add or replace a cookie with the same name, domain, and path, and deletion matches the same key. Rule of thumb: session cookies are Secure, HttpOnly, and SameSite=Lax unless a documented flow needs otherwise.$body$, $code$POST /login HTTP/1.1
Host: api.example.com

HTTP/1.1 200 OK
Set-Cookie: session=8f3a9c; Path=/; Secure; HttpOnly; SameSite=Lax; Max-Age=1800

POST /logout HTTP/1.1
Cookie: session=8f3a9c

HTTP/1.1 200 OK
Set-Cookie: session=; Path=/; Max-Age=0$code$),
    ('cookie-and-session-mechanics', 2, 'Domain, path, and scope', $body$A cookie set without Domain is host-only and is not sent to subdomains; setting Domain widens it to that domain and all subdomains, so one compromised subdomain endangers them all. Path restricts where the browser sends the cookie but is not a security boundary, since any page can issue requests targeting a deeper path. Cookies for a host travel with every request to it, including static assets, unless a narrower path or separate host limits them. Rule of thumb: keep session cookies host-only on the API host.$body$, $code$GET /api/orders HTTP/1.1
Host: admin.example.com

HTTP/1.1 200 OK
Set-Cookie: session=8f3a9c; Domain=example.com; Path=/api

GET /settings HTTP/1.1
Host: shop.example.com

HTTP/1.1 200 OK
Set-Cookie: preference=dark; Path=/; Max-Age=31536000
Set-Cookie: theme=light; Path=/; Max-Age=31536000$code$),
    ('cookie-and-session-mechanics', 3, 'Fixation and rotation', $body$Session fixation occurs when an attacker chooses a session identifier and the victim authenticates with it, leaving the attacker logged in. Rotate the identifier on every privilege change, especially login, and invalidate the old identifier server-side so it cannot be replayed. Continue rotating periodically and after logout, and give sessions both an idle timeout and an absolute lifetime. Server-side sessions can be revoked centrally; self-contained tokens trade that ability for statelessness unless you maintain a revocation list. Rule of thumb: rotate on authentication and treat logout as revocation.$body$, $code$POST /login HTTP/1.1
Cookie: session=old-id

HTTP/1.1 200 OK
Set-Cookie: session=new-id; Path=/; Secure; HttpOnly; SameSite=Lax

GET /profile HTTP/1.1
Cookie: session=old-id

HTTP/1.1 401 Unauthorized$code$),
    ('network-debugging-toolkit', 1, 'Disciplined use of curl', $body$Curl is the reference client for reproducing an HTTP problem. Verbose mode shows request headers, TLS details, and response headers, and --resolve pins a hostname to a chosen address so you can test a specific backend without editing DNS. Timing variables report phases such as name lookup, connect, TLS, and first byte, splitting a slow call into network, handshake, and server components. Exit codes separate connection failures from HTTP error responses. Rule of thumb: reproduce with the smallest command, then add flags one at a time instead of pasting a wall of options.$body$, $code$curl -v --resolve api.example.com:443:203.0.113.20 \
  https://api.example.com/orders/42

curl -s -o /dev/null \
  -w "connect=%{time_connect} tls=%{time_appconnect} first=%{time_starttransfer}\n" \
  https://api.example.com/orders/42$code$),
    ('network-debugging-toolkit', 2, 'Packets, TLS, and debug flags', $body$Packet capture shows retransmissions, resets, and connection lifecycle when application logs run out of answers, and a capture on the server can prove whether a request arrived at all. Encryption hides contents but not timings and connection behavior. Client-side JSSE debug output and openssl s_client expose certificates and negotiated parameters without decryption, and key-log files let analysis tools decrypt sessions when the client supports them. Rule of thumb: capture brief windows with a tight filter, because full captures grow fast and may contain sensitive traffic.$body$, $code$tcpdump -i any -nn -c 20 port 443
tcpdump -i any -nn 'tcp[tcpflags] & tcp-rst != 0'

curl --trace-time -v https://api.example.com/orders 2>&1 | tail -20

openssl s_client -connect api.example.com:443 \
  -servername api.example.com

java -Djavax.net.debug=ssl:handshake -jar app.jar$code$),
    ('network-debugging-toolkit', 3, 'Correlating client and server views', $body$A client timeout looks identical whether the request was never sent, arrived late, or completed after the client gave up. Generate a correlation identifier per request, send it in a header, log it on entry and exit, and compare client-observed timing with server-observed processing time to locate the delay. Gateway access logs add another vantage point for queueing and retries. Without correlation, teams trade guesses across boundaries. Rule of thumb: propagate one request ID end to end and make it visible in logs before an incident, not during one.$body$, $code$GET /orders/42 HTTP/1.1
Host: api.example.com
X-Request-Id: 7f9c2a41

HTTP/1.1 200 OK
X-Request-Id: 7f9c2a41
Server-Timing: db;dur=12.4, total;dur=18.9$code$)
) AS s(slug, sort_order, title, body, starter_code)
JOIN tutorial t ON t.slug = s.slug
WHERE NOT EXISTS (
    SELECT 1
    FROM tutorial_section existing
    WHERE existing.tutorial_id = t.id AND existing.sort_order = s.sort_order
);

INSERT INTO learning_path_tutorial (learning_path_id, tutorial_id, sort_order)
SELECT lp.id, t.id,
       COALESCE((SELECT MAX(existing.sort_order)
                 FROM learning_path_tutorial existing
                 WHERE existing.learning_path_id = lp.id), 0)
       + ROW_NUMBER() OVER (PARTITION BY lp.id ORDER BY t.slug)
FROM learning_path lp
JOIN tutorial t ON t.level = CASE lp.slug
    WHEN 'junior-java-developer' THEN 'Junior'
    WHEN 'mid-java-engineer' THEN 'Mid'
    WHEN 'senior-java-engineer' THEN 'Senior'
    WHEN 'lead-java-engineer' THEN 'Lead'
    WHEN 'principal-java-engineer' THEN 'Principal'
END
WHERE t.slug IN (
    'http-methods-semantics', 'http-status-code-craft', 'http-headers-that-matter',
    'http-caching-in-depth', 'http-2-and-http-3', 'tls-handshake-essentials',
    'connection-reuse-and-pooling', 'timeouts-and-retry-matrix', 'proxies-and-load-balancers',
    'dns-in-service-calls', 'compression-and-payload-strategies', 'websockets-and-sse',
    'content-security-and-cors', 'cookie-and-session-mechanics', 'network-debugging-toolkit'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
