-- V21 — Data structures and algorithms for working engineers.

INSERT INTO tutorial (slug, title, description, level, duration_minutes, published, version)
VALUES
    ('big-o-in-practice', 'Big-O in Practice', 'Understand how growth rates, constants, and memory access patterns shape real latency.', 'Junior', 24, true, 1),
    ('arrays-and-strings-patterns', 'Arrays and Strings Patterns', 'Use arrays and strings efficiently with awareness of resizing, copying, and builder patterns.', 'Junior', 22, true, 1),
    ('hashing-patterns', 'Hashing Patterns', 'Apply hash-based structures safely with correct keys, load-factor awareness, and collision resistance.', 'Junior', 26, true, 1),
    ('two-pointers-and-sliding-windows', 'Two Pointers and Sliding Windows', 'Scan sequences in linear time with pointer and window techniques that replace nested loops.', 'Junior', 24, true, 1),
    ('stacks-and-queues-patterns', 'Stacks and Queues Patterns', 'Use stacks, queues, and deques for parsing, breadth-first search, and bounded production buffers.', 'Mid', 26, true, 1),
    ('linked-list-patterns', 'Linked List Patterns', 'Reason about pointer discipline and choose linked structures only when their trade-offs pay off.', 'Mid', 22, true, 1),
    ('trees-and-traversals', 'Trees and Traversals', 'Traverse trees and binary search trees deliberately and connect balanced trees to real index behavior.', 'Mid', 30, true, 1),
    ('binary-search-patterns', 'Binary Search Patterns', 'Locate boundaries in sorted data with proven variants and binary search over answer spaces.', 'Mid', 28, true, 1),
    ('heaps-and-top-k', 'Heaps and Top-K', 'Drive streaming top-k and scheduling problems with heaps that bound memory and latency.', 'Mid', 30, true, 1),
    ('graphs-basics-bfs-dfs', 'Graphs Basics with BFS and DFS', 'Represent graphs honestly and traverse them with BFS or DFS frameworks that detect cycles.', 'Mid', 32, true, 1),
    ('shortest-path-intuition', 'Shortest Path Intuition', 'Compare BFS, Dijkstra, and Bellman-Ford by problem shape and avoid negative-weight traps.', 'Mid', 34, true, 1),
    ('dynamic-programming-intuition', 'Dynamic Programming Intuition', 'Build dynamic programming solutions from states, transitions, and base cases instead of memorized templates.', 'Senior', 38, true, 1),
    ('greedy-algorithms-when', 'Greedy Algorithms and When They Work', 'Know when a greedy choice is provably safe and when a counterexample should send you elsewhere.', 'Senior', 32, true, 1),
    ('recursion-and-backtracking', 'Recursion and Backtracking', 'Control recursion depth and pruning so recursive solutions stay safe in production processes.', 'Mid', 30, true, 1),
    ('sorting-algorithms-in-depth', 'Sorting Algorithms in Depth', 'Understand comparison sorts, stability, and TimSort behavior that shapes real JDK performance.', 'Junior', 28, true, 1),
    ('bit-manipulation-basics', 'Bit Manipulation Basics', 'Use bit masks for flags and compact state while keeping code readable and correct.', 'Junior', 20, true, 1),
    ('choosing-data-structures-at-work', 'Choosing Data Structures at Work', 'Pick data structures from access patterns, concurrency, and memory budgets rather than habit.', 'Mid', 34, true, 1)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tutorial_section (tutorial_id, title, body_markdown, starter_code, sort_order)
SELECT t.id, s.title, s.body, s.starter_code, s.sort_order
FROM (VALUES
    ('big-o-in-practice', 1, 'Growth Rates vs Wall Time', $body$Big-O describes how work grows with input size, not how fast one machine runs. A hundred-element list with an O(n squared) scan finishes in microseconds, while the same algorithm on ten million rows can dominate a request. Production code mixes sizes: configuration lists stay tiny while tenant data grows without bound. Read complexity as a curve, then ask which operations touch data that can grow. Constants stop mattering exactly where input stops being small, so a faster growth rate always loses eventually. Rule of thumb: compare algorithms at the sizes you actually run in production, not at textbook limits.$body$, $code$// Rough sizes to compare before choosing an algorithm.
record Item(String id, String payload) {}

List<Item> all = repository.loadAll();  // grows with tenants
for (Item item : all) {                 // O(n) per request
    if (item.id().equals(requestedId)) {
        return item;
    }
}
throw new NotFoundException(requestedId);$code$),
    ('big-o-in-practice', 2, 'Constants, Caches, and Memory Access', $body$Two algorithms with the same growth rate can differ by an order of magnitude because of memory access. Scanning contiguous array elements lets the CPU prefetch and reuse cache lines, while following pointers through a tree or linked list pays a miss per node. Java object headers and references add overhead that asymptotic analysis hides. That is why an O(n log n) sort can beat an O(n) hash-based approach when n is small: hashing pays function calls, boxing, and table setup that sorting avoids. At large n the growth rate wins again. Rule of thumb: treat complexity as elimination, then benchmark with realistic data before choosing.$body$, $code$int[] scores = loadScores();  // contiguous, cache friendly
long total = 0;
for (int score : scores) {
    total += score;
}

List<Integer> boxed = loadBoxedScores();  // pointer chase per element
long boxedTotal = 0;
for (int score : boxed) {
    boxedTotal += score;
}$code$),
    ('big-o-in-practice', 3, 'From Complexity to Real Bottlenecks', $body$Asymptotic analysis narrows your options but rarely identifies the bottleneck in a running service. Latency usually comes from waiting: database round trips, lock contention, garbage collection pauses, or deserialization. Profilers and allocation measurements show where time actually goes, and the answer is often I/O shaped rather than algorithmic. Still, complexity reasoning matters when an operation sits in the inner loop of request handling and its input can grow. Use it to reject designs that cannot scale, then measure to pick among viable ones. Rule of thumb: reason about growth, measure wall time, and optimize only the path that profiles hot.$body$, $code$// Keep the hot path linear and allocation free.
Map<String, Item> index = new HashMap<>(expectedSize);
for (Item item : all) {
    index.put(item.id(), item);
}

Item found = index.get(requestedId);
if (found == null) {
    throw new NotFoundException(requestedId);
}$code$),
    ('arrays-and-strings-patterns', 1, 'Contiguous Memory and Access Cost', $body$An array stores elements in one contiguous block, so indexing costs O(1) and sequential scans are cache friendly. Java adds a header and length field per array object, but element access stays direct. ArrayList wraps an array and offers the same random access while growing on demand; LinkedList spends a node object per element and loses locality on every access. For read-heavy, index-based, or scan-heavy workloads, array-backed structures are almost always the right default. Watch very large arrays: allocations above roughly half a GC region can be treated as humongous and stress the collector. Rule of thumb: choose contiguous storage unless you truly need frequent middle insertions.$body$, $code$// Array-backed list: one allocation, direct indexed access.
List<String> tenants = new ArrayList<>(expectedCount);
tenants.add("alpha");
tenants.add("beta");

String first = tenants.get(0);   // O(1)
int count = tenants.size();
for (String tenant : tenants) {  // sequential scan
    counters.increment(tenant);
}$code$),
    ('arrays-and-strings-patterns', 2, 'Resizing Costs and Initial Capacity', $body$ArrayList grows by copying into a larger array, typically increasing capacity by half, so appends are amortized O(1) while a single copy can be expensive and peak memory briefly doubles. When the final size is known or estimable, pass an initial capacity to avoid repeated copies and reallocation churn. Be careful with trimming: trimToSize after a large removal shrinks memory but can trigger another full copy. Prefer bulk operations such as addAll and removeIf, which shift elements once instead of many times. Rule of thumb: estimate the count before building a large list, and let it grow only when the estimate is genuinely unknown.$body$, $code$// Pre-size when the count is known to avoid copy churn.
List<Row> rows = new ArrayList<>(batchSize);
for (Record record : page) {
    rows.add(map(record));
}
rows.trimToSize();  // optional: release unused capacity
process(rows);$code$),
    ('arrays-and-strings-patterns', 3, 'Building Strings Without Quadratic Work', $body$String is immutable, so concatenation creates a new object and copies both operands. Inside a loop this becomes a quadratic copy pattern that shows up as allocation pressure and long young-generation collections. A StringBuilder appends into a growable buffer, giving amortized constant cost per append; call toString once at the end. The compiler may optimize simple concatenation with invokedynamic, but it does not rescue accumulation inside loops with method calls or conditionals. Logging frameworks can also build messages eagerly, so guard debug-level formatting. Rule of thumb: use StringBuilder for loops and use String.join or formatted output for one-shot assembly.$body$, $code$// One buffer, one final copy.
StringBuilder report = new StringBuilder(256);
for (Order order : orders) {
    report.append(order.id()).append("=");
    report.append(order.total()).append(";");
}
String text = report.toString();$code$),
    ('hashing-patterns', 1, 'Maps and Sets as Lookup Indexes', $body$Hash-based collections turn repeated linear searches into constant-time lookups, which is the single biggest practical win in most service code. Building a HashMap once from a list lets a request handler answer membership or join questions in O(1) instead of scanning. HashSet covers duplicate detection, and ConcurrentHashMap covers shared state across threads. The trade-off is memory: each entry carries a node object, references, and a slot in the table, so an index over millions of keys can consume gigabytes. Rule of thumb: measure key count before building large indexes, and prefer bounded structures when the input is untrusted.$body$, $code$Map<String, User> byId = new HashMap<>(users.size());
for (User user : users) {
    byId.put(user.id(), user);
}

for (String requested : requestIds) {
    User user = byId.get(requested);  // O(1) average
    if (user != null) {
        results.add(user);
    }
}$code$),
    ('hashing-patterns', 2, 'equals, hashCode, and Mutable Keys', $body$HashMap finds a bucket by hashCode and then confirms the key with equals. If two equal objects return different hash codes, lookups fail silently: the entry exists but can never be found. Records and generated methods get this right, while hand-written classes often do not. Never mutate a field that participates in hashing or equality after inserting a key, because the entry stays in the old bucket and becomes unreachable. The default load factor is 0.75 and the table doubles when it is exceeded, rehashing every entry. Rule of thumb: use immutable keys, prefer records for composite keys, and never store mutable objects as map keys.$body$, $code$record TenantKey(String tenantId, String region) {}

Map<TenantKey, Quota> quotas = new HashMap<>();
quotas.put(new TenantKey("acme", "eu"), quota);
Quota q = quotas.get(new TenantKey("acme", "eu"));
// Records derive equals and hashCode from their components.$code$),
    ('hashing-patterns', 3, 'Collisions and Adversarial Keys', $body$Every hash table resolves collisions, and worst-case behavior can degrade a lookup from O(1) to O(n) when many keys land in one bucket. Java treeifies a bin after eight entries, but that only helps when keys are mutually comparable; otherwise the bin keeps a linked list. Because String.hashCode is deterministic and well known, an attacker who controls keys can deliberately craft collisions and turn a request handler into a CPU sink. Treat externally supplied keys as untrusted data: cap sizes, validate format, and avoid unbounded maps keyed by raw input. Rule of thumb: hashing cost is only predictable when both the hash function and the input distribution stay partly under your control.$body$, $code$// Bound untrusted key work before it reaches the map.
if (key.length() > MAX_KEY_LENGTH) {
    throw new IllegalArgumentException("key too long");
}
Map<String, Integer> counts = new HashMap<>();
counts.merge(key, 1, Integer::sum);$code$),
    ('two-pointers-and-sliding-windows', 1, 'Linear Scans with Two Positions', $body$Two pointers replace a nested loop with a single pass when each step can safely discard part of the input. In a sorted array, moving the left pointer right increases the sum and moving the right pointer left decreases it, so a pair search runs in O(n) instead of O(n squared). The technique needs a monotone property: something that only grows or only shrinks as pointers move. Reversing in place, merging two sorted sequences, and deduplicating all follow this shape. Rule of thumb: if comparing every pair seems necessary, look for ordering or monotonicity that lets a pointer advance without revisiting positions.$body$, $code$int left = 0, right = values.length - 1;
while (left < right) {
    long sum = (long) values[left] + values[right];
    if (sum == target) return true;
    if (sum < target) left++;
    else right--;
}
return false;$code$),
    ('two-pointers-and-sliding-windows', 2, 'Sliding Windows over Sequences', $body$A window keeps a running aggregate between two indices, adding the incoming element and removing the outgoing one as it slides. Fixed-size windows track sums, counts, or maxima over the last k items; variable windows shrink from the left while a validity condition fails, which finds the longest or shortest subrange in O(n). Correctness depends on the window being able to recover: once an element leaves, it must not be needed again for the current best. Rate limiting, throughput measurement, and log analysis all reduce to windowed aggregates. Rule of thumb: maintain state incrementally and never recompute the window from scratch.$body$, $code$int left = 0;
long windowSum = 0;
for (int right = 0; right < values.length; right++) {
    windowSum += values[right];
    while (windowSum > limit) {
        windowSum -= values[left++];
    }
    best = Math.max(best, right - left + 1);
}$code$),
    ('two-pointers-and-sliding-windows', 3, 'When Sorted Input Unlocks Linear Scan', $body$Sorting first changes the problem: ordered data supports two pointers, binary search, and early exits that unordered data cannot. The cost is O(n log n) time plus a possible copy of the array, and sorting destroys original index order unless you sort records or index pairs. Sometimes that is cheap compared with the alternative; sometimes a hash set is better because it preserves a single pass and does not reorder anything. Decide based on whether order matters to callers and whether the input is already sorted. Rule of thumb: reach for sorting when you need order anyway, and reach for hashing when you need only membership or pairing.$body$, $code$// Sort a defensive copy when callers still need the source order.
int[] sorted = values.clone();
Arrays.sort(sorted);
int left = 0, right = sorted.length - 1;
// Two-pointer scan over the sorted copy follows here.$code$),
    ('stacks-and-queues-patterns', 1, 'Stacks for Matching and Parsing', $body$A stack is the right structure whenever the most recent unfinished item is the next one to resolve. Bracket matching, nested configuration blocks, expression evaluation, and structured-text parsing all follow that push-pop pattern. Prefer ArrayDeque over the legacy Stack class, which synchronizes every operation and belongs to old collection APIs. Always define behavior for an empty stack: pop and peek throw, so guard them or treat an unexpected close as input error. Rule of thumb: if you find yourself tracking nesting depth or matching delimiters, you want a stack.$body$, $code$Deque<Character> open = new ArrayDeque<>();
for (char c : text.toCharArray()) {
    if (c == '(') {
        open.push(c);
    } else if (c == ')') {
        if (open.isEmpty()) return false;
        open.pop();
    }
}
return open.isEmpty();$code$),
    ('stacks-and-queues-patterns', 2, 'Queues for BFS and Bounded Buffers', $body$A queue processes items in arrival order, which is exactly what level-by-level graph traversal and fair work distribution need. ArrayDeque is the default in-process implementation; BlockingQueue variants coordinate producer and consumer threads with put and take. The dangerous choice is an unbounded queue between a fast producer and a slow consumer: memory grows until the process dies, and the failure arrives long after the cause. Prefer bounded queues with a documented rejection or blocking policy, and monitor queue depth. Rule of thumb: never let an untrusted producer feed an unbounded queue.$body$, $code$Queue<Node> queue = new ArrayDeque<>();
queue.add(root);
while (!queue.isEmpty()) {
    Node node = queue.poll();
    visit(node);
    queue.addAll(node.children());
}$code$),
    ('stacks-and-queues-patterns', 3, 'Deque Use Cases in Production Code', $body$ArrayDeque implements both stack and queue operations, so one class covers LIFO, FIFO, and double-ended access such as taking work from either end. A monotonic deque computes sliding-window maxima in linear time by evicting smaller elements from the back. In concurrent code, LinkedBlockingDeque supports work stealing where idle threads pull from the opposite end of busy ones. Keep the discipline explicit: document which end is which, and avoid mixing push and add semantics on the same deque. Rule of thumb: reach for ArrayDeque first, and move to a concurrent deque only when several threads share it.$body$, $code$ArrayDeque<Task> backlog = new ArrayDeque<>();
backlog.addLast(newTask);         // enqueue at tail
Task next = backlog.pollFirst();  // dequeue from head
if (next == null) {
    return Optional.empty();
}
return Optional.of(next.process());$code$),
    ('linked-list-patterns', 1, 'Pointer Discipline and Invariants', $body$Linked list code fails on edge cases, not on the general step: empty lists, single nodes, and head changes are where null dereferences live. Write the loop invariant down before coding, use a dummy head node to absorb head insertions and removals, and never dereference next more than once without a local variable. Fast and slow pointers detect cycles and find midpoints in one pass without extra memory. Reversal in place is three assignments that must happen in the right order. Rule of thumb: if you cannot state the invariant in one sentence, the pointer logic is not ready.$body$, $code$Node slow = head, fast = head;
while (fast != null && fast.next != null) {
    slow = slow.next;
    fast = fast.next.next;
    if (slow == fast) {
        return true;  // cycle detected
    }
}
return false;$code$),
    ('linked-list-patterns', 2, 'When Linked Structures Beat Arrays', $body$A linked list wins when insertion or removal happens at a known node and elements must not move. In practice that situation is rare: finding the node costs a traversal, per-node objects hurt cache locality, and iterating a LinkedList steps through scattered objects. ArrayList shifts elements on middle removal but remains faster for most workloads because shifting is a memory copy and scanning is sequential. Real wins appear with intrusive nodes already embedded in larger objects, or with splicing whole sublists. Rule of thumb: default to arrays and choose linked nodes only after measuring a specific hot path.$body$, $code$// ArrayList: contiguous, indexable, cache friendly.
List<String> buffer = new ArrayList<>(1024);
buffer.add("first");
String head = buffer.get(0);
buffer.remove(0);  // O(n) shift, still fast in practice$code$),
    ('linked-list-patterns', 3, 'Linked Nodes Inside the JDK', $body$The JDK still relies on linked nodes where the shape is essential. ConcurrentLinkedQueue and LinkedTransferQueue give non-blocking FIFO behavior. LinkedHashMap threads nodes through insertion or access order and supports LRU-style eviction with a single override. ConcurrentHashMap bins fall back to linked lists when tree bins cannot compare keys. These structures hide pointer work behind tested APIs, which is exactly the point: do not hand-roll linked lists for concurrency. Use the library implementation, size your structures, and let it handle memory ordering. Rule of thumb: consume linked structures through JDK abstractions rather than inventing your own.$body$, $code$class LruCache<K, V> extends LinkedHashMap<K, V> {
    private final int capacity;

    LruCache(int capacity) {
        super(capacity, 0.75f, true);  // access order
        this.capacity = capacity;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return size() > capacity;
    }
}$code$),
    ('trees-and-traversals', 1, 'DFS Orders and Recursion Costs', $body$Depth-first traversal visits a node before its children (preorder), between them (inorder), or after them (postorder). Inorder on a binary search tree yields sorted keys; postorder is the natural fit for computing subtree aggregates or deleting nodes. Recursive DFS consumes stack proportional to tree height, and an unbalanced tree built from sorted inserts degenerates into a linked list, so height can reach n and deep recursion can throw StackOverflowError. Iterative traversal with an explicit deque removes that risk. Rule of thumb: recursion is fine for balanced shapes, but read input ordering before trusting tree height.$body$, $code$void inorder(Node node, List<String> out) {
    if (node == null) {
        return;
    }
    inorder(node.left, out);
    out.add(node.key);
    inorder(node.right, out);
}$code$),
    ('trees-and-traversals', 2, 'BFS and Level Reasoning', $body$Breadth-first traversal processes nodes in order of distance from the root, which makes it the tool for level-order output, nearest-match search, and unweighted shortest paths. A queue holds the frontier; adding children as each node is dequeued naturally separates levels. The cost is memory: the frontier can grow as wide as the tree, while DFS keeps only one path. That symmetry matters when trees or graphs come from data, because a wide fan-out can exhaust heap faster than depth can exhaust the call stack. Rule of thumb: choose BFS when distance or levels matter, and bound the frontier when the shape is unknown.$body$, $code$Queue<Node> frontier = new ArrayDeque<>();
frontier.add(root);
while (!frontier.isEmpty()) {
    int levelSize = frontier.size();
    for (int i = 0; i < levelSize; i++) {
        Node node = frontier.poll();
        process(node);
        frontier.addAll(node.children());
    }
}$code$),
    ('trees-and-traversals', 3, 'Balanced Trees and Indexed Lookups', $body$A binary search tree guarantees O(log n) only while it stays balanced; adversarial or sorted input can make it O(n). Self-balancing variants such as red-black and AVL trees restore the bound with rotations, and Java ships TreeMap and TreeSet as red-black trees with ordered navigation, range views, and floor or ceiling lookups. Database indexes use the same idea with much higher fanout: a B-tree node holds hundreds of keys, so millions of rows fit in three or four levels of page reads. Rule of thumb: never hand-roll a BST in service code; use a tree map, or a database index, for ordered lookups.$body$, $code$TreeMap<Instant, Order> orders = new TreeMap<>();
orders.put(order.createdAt(), order);

Instant since = Instant.now().minus(Duration.ofHours(1));
// Ordered range view: no full scan of unrelated keys.
Collection<Order> recent = orders.tailMap(since).values();$code$),
    ('binary-search-patterns', 1, 'Searching Sorted Data Safely', $body$Binary search halves the remaining range each step, giving O(log n) lookups, but its details are easy to get wrong. Compute the midpoint as lo + (hi - lo) / 2 to avoid overflow with large indices, and keep ranges half-open so lo equals hi means empty. The JDK contract in Arrays.binarySearch and Collections.binarySearch returns the index if found, otherwise a negative value that encodes the insertion point, so always test for less than zero before using the result. Rule of thumb: write the loop invariant in a comment, and test four boundaries: not found, first element, last element, and empty input.$body$, $code$int lo = 0, hi = sorted.length;
while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (sorted[mid] < target) {
        lo = mid + 1;
    } else {
        hi = mid;
    }
}
return lo;  // first index with value >= target$code$),
    ('binary-search-patterns', 2, 'Lower Bound and Upper Bound Variants', $body$Many production searches look for boundaries rather than exact matches: the first index at or after a timestamp, the number of entries strictly before a version, or the first version above a threshold. Lower bound finds the first index whose value is not less than the target; upper bound finds the first index strictly greater. Both variants return an insertion point when the target is absent, which makes them ideal for range queries and deduplication. The pattern is one loop with a different update rule, so name the predicate clearly. Rule of thumb: search for a partition point, not for equality, whenever duplicates or ranges are involved.$body$, $code$int idx = Arrays.binarySearch(sorted, target);
if (idx >= 0) {
    return sorted[idx];
}
int insertionPoint = -(idx + 1);  // JDK contract
return insertionPoint < sorted.length ? sorted[insertionPoint] : null;$code$),
    ('binary-search-patterns', 3, 'Binary Search on the Answer', $body$When the answer is a number in a known range and feasibility changes monotonically with that number, you can binary search the answer itself. Examples include the smallest batch size that meets a throughput target, the minimum capacity that fits all items, or the highest rate limit that stays within latency. Each step evaluates a predicate, so total cost is predicate cost times log of the range. The main risk is a predicate that is not truly monotone, which yields a confident wrong answer. Rule of thumb: prove that feasibility flips once, then search the boundary between failing and passing halves.$body$, $code$// Smallest batch size whose feasibility predicate holds.
int lo = 1, hi = maxBatch;
while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (fits(mid)) {
        hi = mid;
    } else {
        lo = mid + 1;
    }
}
return lo;$code$),
    ('heaps-and-top-k', 1, 'Priority Queues and Heap Semantics', $body$A PriorityQueue is a binary heap: the head is always the smallest element, or the largest with a comparator, while the rest of the array has no sorted order. Insertion and removal cost O(log n); peeking costs O(1). Iteration does not return elements in priority order, which is a common and expensive misunderstanding in production code. Heaps are ideal when you repeatedly need the extreme element and do not care about global order. If you need fully sorted iteration, sort instead. Rule of thumb: use a heap when you need the next best item, not a list of items in order.$body$, $code$PriorityQueue<Job> queue = new PriorityQueue<>(
    Comparator.comparing(Job::deadline));
queue.add(new Job("nightly", deadline));
Job next = queue.poll();   // earliest deadline
Job peeked = queue.peek(); // same value, not removed$code$),
    ('heaps-and-top-k', 2, 'Streaming Top-K Under Bounded Memory', $body$To keep the k largest values from a stream, maintain a min-heap of size k: push each value, and when size exceeds k, poll the smallest. The heap holds exactly the survivors, so memory stays O(k) no matter how long the stream runs, and time is O(n log k) instead of O(n log n) plus an O(n) copy for a full sort. Choose a min-heap for the largest k and a max-heap for the smallest k; getting the direction backwards silently returns the wrong set. Track ties deliberately, because equal keys may evict elements callers still care about. Rule of thumb: bounded top-k lists belong in heaps, not in sorted collections.$body$, $code$PriorityQueue<Integer> topK = new PriorityQueue<>();  // min-heap
for (int value : stream) {
    topK.add(value);
    if (topK.size() > k) {
        topK.poll();  // evict the smallest survivor
    }
}
return topK;  // k largest values, not yet ordered$code$),
    ('heaps-and-top-k', 3, 'Schedulers, Retries, and Rate Limits', $body$Timers and schedulers are heaps in disguise: the next task due is the minimum by deadline, so a priority queue gives O(log n) insertion and quick extraction. Retry queues with exponential backoff use the same shape, ordering attempts by their earliest allowed time. Rate limiters and token buckets combine a bounded queue with time-based admission decisions, where the deque keeps the last window of requests. The production risk is unbounded growth: every scheduled task occupies memory until it fires, so cap outstanding work and reject excess. Rule of thumb: any structure that answers what runs next is a heap problem.$body$, $code$record ScheduledTask(Instant dueAt, Runnable action) {}

PriorityQueue<ScheduledTask> pending = new PriorityQueue<>(
    Comparator.comparing(ScheduledTask::dueAt));
pending.add(new ScheduledTask(Instant.now().plusSeconds(5), this::flush));

ScheduledTask due = pending.peek();$code$),
    ('graphs-basics-bfs-dfs', 1, 'Choosing a Graph Representation', $body$An adjacency list stores each vertex with its neighbors and costs O(V + E) memory, which suits sparse graphs such as service call graphs, dependency trees, and social follows. An adjacency matrix costs O(V squared) memory but answers edge-existence in O(1), which pays off only for dense graphs or repeated membership questions on a small vertex set. Edge lists are convenient for algorithms that relax edges globally, such as Bellman-Ford. Convert deliberately and document direction: mixing directed and undirected assumptions is a leading source of wrong traversal results. Rule of thumb: start with adjacency lists, and move to matrices only when density or lookup patterns justify the memory.$body$, $code$Map<String, List<String>> adjacency = new HashMap<>();
adjacency.put("api", List.of("db", "cache"));
adjacency.put("worker", List.of("db"));

for (String neighbor : adjacency.getOrDefault("api", List.of())) {
    process(neighbor);
}$code$),
    ('graphs-basics-bfs-dfs', 2, 'Traversal Frameworks with BFS and DFS', $body$Both traversals share one skeleton: track visited vertices, take the next frontier item, then enqueue or push unvisited neighbors. Mark visited when a vertex enters the frontier, not when it leaves, or the frontier can hold the same vertex many times. BFS uses a queue and explores by distance; DFS uses a stack or recursion and exhausts one branch before backtracking. Both run in O(V + E) with adjacency lists, but DFS can push the call stack as deep as the graph and overflow on long chains. Rule of thumb: use BFS for nearest or level questions, DFS for connectivity and structure, and prefer the iterative form for untrusted input.$body$, $code$Deque<String> frontier = new ArrayDeque<>();
Set<String> visited = new HashSet<>();
frontier.add(start);
visited.add(start);
while (!frontier.isEmpty()) {
    String node = frontier.poll();
    for (String next : adjacency.getOrDefault(node, List.of())) {
        if (visited.add(next)) {
            frontier.add(next);
        }
    }
}$code$),
    ('graphs-basics-bfs-dfs', 3, 'Cycle Detection and Dependency Order', $body$A cycle in a directed graph means no valid processing order exists and, in build or deployment graphs, that the pipeline can never complete. Detection uses three states during DFS: unvisited, in progress on the current stack, and finished; an edge back to an in-progress vertex proves a cycle. The alternative is Kahn topological sort, repeatedly removing vertices with zero in-degree and reporting failure when vertices remain. Both are linear in V plus E. Cycles in service dependency or import graphs usually indicate a design problem, so report the cycle path, not just its existence. Rule of thumb: validate graphs for cycles at the boundary where they enter the system.$body$, $code$Map<String, Integer> inDegree = computeInDegrees(edges);
Deque<String> ready = new ArrayDeque<>();
for (Map.Entry<String, Integer> entry : inDegree.entrySet()) {
    if (entry.getValue() == 0) {
        ready.add(entry.getKey());
    }
}
// Fewer than V processed vertices means a cycle exists.$code$),
    ('shortest-path-intuition', 1, 'BFS for Unweighted Distances', $body$When every edge costs the same, BFS finds shortest paths because it settles vertices in nondecreasing distance order. Distances are recorded as each vertex is first reached, and the first time a vertex enters the frontier is already optimal. This covers hop counts in service meshes, message routing with equal costs, and reachability style questions. Do not reach for Dijkstra here: it adds heap overhead and complexity without buying anything when weights are equal. The pitfall is mixing weighted and unweighted edges and silently computing hop count instead of cost. Rule of thumb: if all edges cost one, BFS is the complete answer and anything more elaborate is a bug waiting to happen.$body$, $code$Map<String, Integer> distance = new HashMap<>();
Deque<String> queue = new ArrayDeque<>();
distance.put(start, 0);
queue.add(start);
while (!queue.isEmpty()) {
    String node = queue.poll();
    for (String next : adjacency.getOrDefault(node, List.of())) {
        if (!distance.containsKey(next)) {
            distance.put(next, distance.get(node) + 1);
            queue.add(next);
        }
    }
}$code$),
    ('shortest-path-intuition', 2, 'Dijkstra for Non-Negative Weights', $body$Dijkstra extends BFS by always settling the unsettled vertex with the smallest known distance, using a priority queue. With adjacency lists it runs in O((V + E) log V). Lazy deletion is the practical implementation: push improved distances and skip stale entries when they surface. The algorithm requires non-negative weights, because a settled vertex is never revisited; a later negative edge could have offered a shorter path that is now ignored. Latency, distance, and cost are non-negative by nature, so Dijkstra fits most production routing. Rule of thumb: use Dijkstra for real costs, and confirm that no negative edges exist before trusting it.$body$, $code$PriorityQueue<int[]> frontier = new PriorityQueue<>(
    Comparator.comparingInt(entry -> entry[1]));
frontier.add(new int[] {start, 0});
while (!frontier.isEmpty()) {
    int[] current = frontier.poll();
    if (current[1] > best[current[0]]) {
        continue;  // stale entry from a later improvement
    }
    // Relax neighbors and push improved distances here.
}$code$),
    ('shortest-path-intuition', 3, 'Bellman-Ford and Negative Edges', $body$Bellman-Ford relaxes every edge up to V minus one times, so it tolerates negative edge weights and can detect negative cycles by checking whether any edge still improves after the final pass. The cost is O(V times E), far heavier than Dijkstra, which is why it appears mainly when negative values are meaningful: credits in settlement, penalties in scheduling, or discounts in routing. A negative cycle means no shortest path exists, because you can loop forever and decrease cost; a detector must treat that as an error, not a result. Rule of thumb: default to Dijkstra, and switch to Bellman-Ford only when negative weights are a real domain concept.$body$, $code$long[] distance = new long[vertices];
Arrays.fill(distance, Long.MAX_VALUE / 4);
distance[source] = 0;
for (int pass = 0; pass < vertices - 1; pass++) {
    for (Edge edge : edges) {
        if (distance[edge.from()] + edge.weight() < distance[edge.to()]) {
            distance[edge.to()] = distance[edge.from()] + edge.weight();
        }
    }
}$code$),
    ('dynamic-programming-intuition', 1, 'States, Transitions, and Base Cases', $body$Dynamic programming applies when a problem splits into overlapping subproblems whose optimal solutions combine. Define the state first: precisely which subproblem a table cell represents. Then write the transition relating a state to smaller states, and finally the base cases that stop the recurrence. Memoized recursion follows the natural recurrence; tabulation iterates in dependency order and avoids call overhead. Most production failures come from a state that omits a needed input, producing answers that are subtly wrong instead of crashing. Rule of thumb: describe the state in one sentence with all its dimensions, then derive the transition from that sentence.$body$, $code$// State: ways to reach step n. Transition: n - 1 plus n - 2.
long previous = 1;  // base: step 0
long current = 1;   // base: step 1
for (int step = 2; step <= requested; step++) {
    long next = previous + current;
    previous = current;
    current = next;
}
return current;$code$),
    ('dynamic-programming-intuition', 2, 'A Worked Example: Fewest Coins', $body$For making an amount from coin denominations with the fewest coins, let dp[a] be the minimum coins needed for amount a, with dp[0] equal to zero. The transition tries each coin: dp[a] equals one plus the minimum dp[a - coin] over coins not exceeding a, or infinity when no combination works. Filling amounts in increasing order guarantees that every smaller state is ready. The table costs O(amount) memory and O(amount times coins) time; the sentinel must stay above any feasible answer to avoid overflow. Rule of thumb: after writing a transition, verify the base case and the unreachable sentinel, because those lines carry most of the correctness.$body$, $code$int[] dp = new int[target + 1];
Arrays.fill(dp, Integer.MAX_VALUE);
dp[0] = 0;
for (int amount = 1; amount <= target; amount++) {
    for (int coin : coins) {
        if (coin <= amount && dp[amount - coin] != Integer.MAX_VALUE) {
            dp[amount] = Math.min(dp[amount], dp[amount - coin] + 1);
        }
    }
}
return dp[target];$code$),
    ('dynamic-programming-intuition', 3, 'Recognition and Cost Bounds', $body$Recognize DP when subproblems repeat and an optimal solution contains optimal solutions to them. Compute cost as number of states times transition work, then check whether the table fits memory; many recurrences need only the previous row or a small window, collapsing to constant or linear space. Beware of using dynamic programming as a reflex: problems with a provable greedy rule or a closed form do not need a table. Also watch for pseudo-polynomial state sizes, where the table grows with numeric values rather than input count. Rule of thumb: estimate states and memory before coding, and shrink the table dimension as soon as the transition allows.$body$, $code$// Two rows instead of a full table when only the previous row matters.
int[] previous = new int[capacity + 1];
int[] current = new int[capacity + 1];
for (int item : items) {
    for (int c = 0; c <= capacity; c++) {
        current[c] = (c < item) ? previous[c]
                : Math.max(previous[c], previous[c - item] + 1);
    }
    int[] swap = previous;
    previous = current;
    current = swap;
}$code$),
    ('greedy-algorithms-when', 1, 'Exchange Arguments and Proof', $body$A greedy algorithm is correct only when a locally best choice can always be part of some globally optimal solution. The usual proof is an exchange argument: take an optimal solution, replace its first differing choice with the greedy one, and show the result is still optimal and no worse. Interval scheduling by earliest finishing time is the classic case; the exchange works because finishing earlier never blocks future options. Without such an argument, greedy code is just a heuristic that happens to pass your tests. Rule of thumb: for every greedy loop, state the invariant that makes discarding alternatives safe, or label the code as heuristic.$body$, $code$// Greedy interval scheduling: earliest finishing time wins.
List<Interval> ordered = new ArrayList<>(intervals);
ordered.sort(Comparator.comparing(Interval::end));
Instant lastEnd = Instant.MIN;
int selected = 0;
for (Interval interval : ordered) {
    if (!interval.start().isBefore(lastEnd)) {
        selected++;
        lastEnd = interval.end();
    }
}$code$),
    ('greedy-algorithms-when', 2, 'Counterexamples and When Greedy Fails', $body$Greedy fails precisely when a locally attractive choice removes a better global combination. Picking the highest value-to-weight ratio first fails for 0/1 knapsack because taking a heavy high-ratio item can block two lighter items. Coin change with denominations 1, 3, and 4 fails for amount 6: greedy takes 4 then 1 then 1, while 3 plus 3 is better. These examples are compact enough to encode as unit tests, which is the practical defense. Rule of thumb: before shipping a greedy rule, search small inputs for a counterexample; if you cannot find one, try to prove the exchange argument.$body$, $code$// Greedy fails here: amount 6, coins {4, 3, 1}.
int greedyCoins = 0, remaining = 6;
for (int coin : new int[] {4, 3, 1}) {
    while (remaining >= coin) {
        remaining -= coin;
        greedyCoins++;  // 3 coins, but 3 + 3 needs only 2
    }
}$code$),
    ('greedy-algorithms-when', 3, 'Greedy Heuristics in Production Systems', $body$Production systems use greedy rules constantly: least-loaded routing, earliest-deadline-first scheduling, evicting the least recently used entry, or placing each task on the first node with capacity. These choices are heuristics, accepted because they are fast, predictable, and close enough under real workloads, not because they are provably optimal. Their failure modes are systematic: a hot shard attracts more traffic, or a cache eviction pattern thrashes under a scan. Guard them with metrics, caps, and fallbacks. Rule of thumb: treat every unproven greedy rule as an experiment and measure regret, fairness, and tail latency before trusting it at scale.$body$, $code$// Heuristic routing with an explicit fallback.
Node target = nodes.stream()
    .filter(node -> node.load() < node.capacity())
    .min(Comparator.comparingDouble(Node::load))
    .orElseThrow(() -> new NoCapacityException());
if (target.load() > HIGH_WATERMARK) {
    metrics.warnOverloaded(target.id());
}$code$),
    ('recursion-and-backtracking', 1, 'Recursion Depth and Stack Limits', $body$Every recursive call occupies a frame on the thread stack, and Java threads get a fixed stack size, commonly hundreds of kilobytes to a megabyte. Depth is therefore a resource: a recursive descent over input that can be deep, such as a long file path or a chained structure, risks StackOverflowError, which is an Error and may leave work half done. The JVM does not perform tail-call elimination, so a tail-recursive-looking method still consumes frames. Convert to iteration with an explicit deque when depth scales with input. Rule of thumb: recursion is safe when depth is bounded by construction, such as log n for balanced trees.$body$, $code$// Iterative version of a depth count: no call stack involved.
int depth(String path) {
    int count = 1;
    for (int i = 0; i < path.length(); i++) {
        if (path.charAt(i) == '/') {
            count++;
        }
    }
    return count;
}$code$),
    ('recursion-and-backtracking', 2, 'Backtracking with Pruning', $body$Backtracking explores a decision tree by choosing a candidate, recursing, then undoing the choice. Raw exploration is exponential, so the value comes from pruning: reject partial states that cannot lead to a valid solution, order candidates to find success early, and stop as soon as one answer is enough. Pruning must be sound; an incorrect bound silently removes valid solutions. Keep the undo step exactly symmetric with the choose step, ideally adjacent in code. Rule of thumb: state the pruning condition and confirm it cannot discard a valid completion, then measure how many nodes remain.$body$, $code$void search(int[] candidates, int target, int index,
            List<Integer> chosen, List<List<Integer>> results) {
    if (target == 0) {
        results.add(List.copyOf(chosen));
        return;
    }
    if (index == candidates.length || target < 0) {
        return;  // prune: overshoot or no candidates left
    }
    chosen.add(candidates[index]);
    search(candidates, target - candidates[index], index + 1, chosen, results);
    chosen.remove(chosen.size() - 1);
    search(candidates, target, index + 1, chosen, results);
}$code$),
    ('recursion-and-backtracking', 3, 'Iterative Alternatives in Service Code', $body$Production code often replaces recursion even when it is elegant, because depth depends on data that arrives at runtime. An explicit stack holds pending work in the heap, where exhaustion is a managed OutOfMemoryError with size limits you can monitor, instead of a per-thread stack overflow. Iterative traversal also allows pausing, resuming, and compensating work, which recursive frames cannot do without exceptions. Keep recursion for bounded structures such as balanced trees, small configuration graphs, or divide-and-conquer over arrays sliced in half. Rule of thumb: if depth is not provably bounded and small, use an explicit worklist.$body$, $code$Deque<String> worklist = new ArrayDeque<>();
worklist.push(root);
while (!worklist.isEmpty()) {
    String node = worklist.pop();
    process(node);
    for (String child : childrenOf(node)) {
        worklist.push(child);
    }
}$code$),
    ('sorting-algorithms-in-depth', 1, 'Comparison Sorts and Their Bounds', $body$Any sort that learns order only by comparing elements needs at least n log n comparisons in the worst case, so no comparison sort can beat that bound. Quicksort is fast in practice thanks to locality but degrades to quadratic time on adversarial pivots and deep recursion on skewed partitions. Heapsort guarantees n log n with constant extra space but scatters accesses across the array. Merge sort is stable with predictable n log n but needs auxiliary memory. Java chooses per data type and size rather than applying one algorithm everywhere. Rule of thumb: know whether you need stability or worst-case guarantees, and let the JDK choose unless measurements say otherwise.$body$, $code$// Same n log n guarantee, very different constants.
List<Order> byDate = new ArrayList<>(orders);
byDate.sort(Comparator.comparing(Order::createdAt));
List<Order> byTotal = new ArrayList<>(orders);
byTotal.sort(Comparator.comparingLong(Order::totalCents));$code$),
    ('sorting-algorithms-in-depth', 2, 'Stability and JDK Sort Behavior', $body$A stable sort preserves the relative order of elements that compare equal, which matters when sorting by several keys or when existing order encodes meaning such as arrival sequence. Arrays.sort and Collections.sort on objects use TimSort, a stable adaptive merge sort that exploits existing runs and can approach linear time on nearly sorted data, but it may also throw when it detects a broken comparator. Primitive arrays use dual-pivot quicksort, which is not stable, though stability is meaningless for raw numbers. Rule of thumb: sort objects when the order of equal keys matters, and never assume stability without checking the exact overload.$body$, $code$// Stable sort keeps insertion order for equal keys.
List<Task> tasks = new ArrayList<>(pending);
tasks.sort(Comparator.comparingInt(Task::priority));
for (Task task : tasks) {
    dispatch(task);
}$code$),
    ('sorting-algorithms-in-depth', 3, 'When Sorting Becomes the Bottleneck', $body$Sorting large collections costs CPU, memory, and copies, and it becomes the bottleneck when done per request or per row. Common symptoms are long young-generation pauses from boxing and large temporary arrays, plus latency spikes proportional to n log n. Options depend on the goal: a bounded top-k needs only a heap, an already ordered source needs no sort, and an indexed database query can return rows in order for free. Precompute order keys so the hot path only compares them. Rule of thumb: sort once at the boundary where the data is stable, not repeatedly on every read path.$body$, $code$// Bounded top-k avoids sorting the whole stream.
PriorityQueue<Order> smallest = new PriorityQueue<>(
    Comparator.comparingLong(Order::totalCents).reversed());
for (Order order : incoming) {
    smallest.add(order);
    if (smallest.size() > 100) {
        smallest.poll();
    }
}$code$),
    ('bit-manipulation-basics', 1, 'Flags and Permission Masks', $body$Bit masks pack many boolean decisions into a single integer, which is how file permissions, feature toggles, and protocol flags travel over the wire. A flag is one bit, checked with mask and flag not equal to zero, set with or-equals, and cleared with and-equals-not. A long gives sixty-four independent flags; choosing int over long is a documented capacity decision, not an accident. The readability cost is real, so name constants and wrap the operations in a small type with methods such as has, add, and remove. Rule of thumb: use bitmasks at boundaries such as storage or protocol fields, and use EnumSet for in-process flag sets.$body$, $code$static final int READ = 1 << 0;
static final int WRITE = 1 << 1;
static final int ADMIN = 1 << 2;

int permissions = READ | WRITE;
boolean canWrite = (permissions & WRITE) != 0;
permissions |= ADMIN;   // grant
permissions &= ~WRITE;  // revoke$code$),
    ('bit-manipulation-basics', 2, 'Idioms Worth Knowing', $body$A few bit idioms earn their place. The expression n and n minus one clears the lowest set bit, so comparing it to zero identifies powers of two, and repeating that clearing counts set bits. Integer.highestOneBit and numberOfTrailingZeros replace hand-written loops for capacity rounding and index math. Java integers are signed, so unsigned right shift is needed before masking high bits, and shift distances are taken modulo thirty-two for int, which can hide mistakes when shift counts are computed. Rule of thumb: recognize these idioms when reading code, but introduce them only where they express intent better than an arithmetic alternative.$body$, $code$boolean isPowerOfTwo = value > 0 && (value & (value - 1)) == 0;
int lowestSetBitValue = value & -value;
int setBitCount = Integer.bitCount(value);
int capacity = Integer.highestOneBit(value) << 1;
int index = Integer.numberOfTrailingZeros(value);$code$),
    ('bit-manipulation-basics', 3, 'Readability and Safety Limits', $body$Bit tricks can make correct code unmaintainable: a magic mask and a shift chain tell a future reader nothing about domain meaning. Reserve bitwise logic for compact flags, checksums, protocol decoding, and performance-critical inner loops with measurements behind them. When you use it, define named constants, document bit ranges and signedness, and add tests for the sign bit and the all-ones case, where shifts and inversions behave unexpectedly. For business rules, an enum set or a record with typed fields is usually clearer and just as fast after the first level of caching. Rule of thumb: bitwise code must justify itself with a boundary or a measured win.$body$, $code$// EnumSet keeps flags type safe without magic numbers.
EnumSet<Feature> enabled = EnumSet.of(Feature.SEARCH, Feature.EXPORT);
if (enabled.contains(Feature.SEARCH)) {
    serveSearch();
}
enabled.remove(Feature.EXPORT);$code$),
    ('choosing-data-structures-at-work', 1, 'Start from Access Patterns', $body$Choose a structure by writing down how it will be used: which key locates an element, whether iteration order matters, how often elements are inserted or removed, and whether lookups must be ordered. Sequential scans and indexed reads suggest ArrayList or arrays; key lookups suggest HashMap; sorted ranges and nearest-key queries suggest TreeMap or a database index; FIFO and LIFO suggest ArrayDeque. Estimate cardinality too, because an O(1) structure with a large constant loses to a simple list when the data is tiny. Rule of thumb: enumerate operations and their frequencies before naming a class.$body$, $code$// Key lookup on the read path.
Map<String, Tenant> byId = new HashMap<>(tenants.size());
for (Tenant tenant : tenants) {
    byId.put(tenant.id(), tenant);
}
Tenant tenant = byId.get(requestedId);$code$),
    ('choosing-data-structures-at-work', 2, 'Mutability, Sharing, and Concurrency', $body$A data structure shared across threads needs either immutability, external locking, or a concurrent implementation with the semantics you require. ConcurrentHashMap offers atomic compound operations and weakly consistent iterators that never throw on concurrent modification and may or may not reflect updates; it refuses null keys and values. Synchronized collections protect each call but not compound sequences, so check-then-act still races. Copying into an immutable snapshot is often the simplest correct answer for configuration and small reference data. Rule of thumb: decide the sharing model before the data structure, because it constrains every option afterwards.$body$, $code$ConcurrentMap<String, Counter> shared = new ConcurrentHashMap<>();
shared.computeIfAbsent("requests", key -> new Counter()).increment();

// Immutable snapshot for configuration data.
Map<String, String> loaded = loadConfig();
Map<String, String> config = Map.copyOf(loaded);$code$),
    ('choosing-data-structures-at-work', 3, 'Memory Budgets and Collection Overhead', $body$Collections cost far more than their element count suggests. A HashMap entry carries a node object with hash, key, value, and next reference, plus a slot in a table sized above the load-factor threshold; boxed primitives add another object per value. A million-entry map of longs can easily consume tens of megabytes against eight megabytes of raw data. Symptoms are frequent full collections, humongous allocations, and container memory limits. Options include primitive-specialized structures, arrays of fields instead of maps, or moving cold data to a store. Rule of thumb: estimate bytes per entry, multiply by peak cardinality, and compare with the heap budget.$body$, $code$// int-keyed maps of primitives box on both key and value.
Map<Integer, Integer> counters = new HashMap<>();
counters.merge(tenantId, 1, Integer::sum);

// Arrays avoid object overhead when the key space is dense.
int[] denseCounters = new int[maxTenantId + 1];
denseCounters[tenantId]++;$code$)
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
    'arrays-and-strings-patterns', 'big-o-in-practice', 'binary-search-patterns',
    'bit-manipulation-basics', 'choosing-data-structures-at-work',
    'dynamic-programming-intuition', 'graphs-basics-bfs-dfs',
    'greedy-algorithms-when', 'hashing-patterns', 'heaps-and-top-k',
    'linked-list-patterns', 'recursion-and-backtracking',
    'shortest-path-intuition', 'sorting-algorithms-in-depth',
    'stacks-and-queues-patterns', 'trees-and-traversals',
    'two-pointers-and-sliding-windows'
)
AND NOT EXISTS (
    SELECT 1
    FROM learning_path_tutorial existing
    WHERE existing.learning_path_id = lp.id AND existing.tutorial_id = t.id
);
