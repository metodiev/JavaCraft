#!/usr/bin/env bash
# Compiles every challenge's public tests against its reference solution (must all pass)
# and against its starter (must have at least one failure). Needs a local JDK 21+.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
content="$root/backend/src/main/resources/challenge-content"
solutions="$root/backend/src/test/resources/challenge-solutions"
runner="$(mktemp -d)"
trap 'rm -rf "$runner"' EXIT
cat > "$runner/Run.java" <<'JAVA'
import java.net.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;

public class Run {
    public static void main(String[] a) throws Exception {
        var loader = new URLClassLoader(new URL[] {Path.of(a[0]).toUri().toURL()}, ClassLoader.getPlatformClassLoader());
        @SuppressWarnings("unchecked")
        var tests = (Map<String, Callable<Boolean>>) loader.loadClass("PublicTests").getMethod("tests").invoke(null);
        int passed = 0;
        for (var e : tests.entrySet()) {
            var ok = new boolean[1];
            Thread t = new Thread(() -> { try { ok[0] = Boolean.TRUE.equals(e.getValue().call()); } catch (Throwable x) { } });
            t.setDaemon(true);
            t.start();
            t.join(2000);
            if (!t.isAlive() && ok[0]) passed++; else System.out.println("  FAIL " + e.getKey());
        }
        System.out.println("RESULT " + passed + " " + tests.size());
        Runtime.getRuntime().halt(0);
    }
}
JAVA
javac -d "$runner" "$runner/Run.java" || exit 1
status=0
for dir in "$content"/*/; do
  slug="$(basename "$dir")"
  [ -f "$dir/PublicTests.java" ] || continue
  for variant in solution starter; do
    out="$(mktemp -d)"
    src="$solutions/$slug/Main.java"; [ "$variant" = starter ] && src="$dir/Main.java"
    if ! javac -proc:none -d "$out" "$src" "$dir/PublicTests.java" 2>"$out.err"; then
      echo "COMPILE ERROR $slug ($variant)"; cat "$out.err"; status=1; continue
    fi
    res="$(java -cp "$runner" Run "$out" 2>&1)"
    line="$(echo "$res" | grep '^RESULT')"
    p="$(echo "$line" | awk '{print $2}')"; t="$(echo "$line" | awk '{print $3}')"
    if [ "$variant" = solution ] && { [ -z "$t" ] || [ "$p" != "$t" ]; }; then
      echo "SOLUTION FAILS $slug: $line"; echo "$res"; status=1
    elif [ "$variant" = starter ] && [ -n "$t" ] && [ "$p" = "$t" ]; then
      echo "STARTER PASSES $slug (tests too weak): $line"; status=1
    fi
    rm -rf "$out" "$out.err"
  done
done
[ $status -eq 0 ] && echo "All challenge contracts verified."
exit $status
