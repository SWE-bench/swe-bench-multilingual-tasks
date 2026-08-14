#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
git status
git show
git -c core.fileMode=false diff b0ba151102a6c1b2e0e4c419c6482a64677c9b40
rm -f tests/basics/string_format_intbig.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/basics/string_format_intbig.py b/tests/basics/string_format_intbig.py
new file mode 100644
index 000000000000..a36c36752e70
--- /dev/null
+++ b/tests/basics/string_format_intbig.py
@@ -0,0 +1,15 @@
+# basic functionality test for {} format string using large integers
+
+
+def test(fmt, *args):
+    print("{:8s}".format(fmt) + ">" + fmt.format(*args) + "<")
+
+
+# Separator formatter
+
+test("{:,}", 123_456_789_012_345_678_901_234_567)
+test("{:,}", 23_456_789_012_345_678_901_234_567)
+test("{:,}", 3_456_789_012_345_678_901_234_567)
+test("{:,}", -123_456_789_012_345_678_901_234_567)
+test("{:,}", -23_456_789_012_345_678_901_234_567)
+test("{:,}", -3_456_789_012_345_678_901_234_567)

EOF_114329324912
source ./tools/ci.sh
ci_unix_build_helper VARIANT=standard
gcc -shared -o tests/ports/unix/ffi_lib.so tests/ports/unix/ffi_lib.c
: '>>>>> Start Test Output'
(cd tests && MICROPY_CPYTHON3=python3 MICROPY_MICROPYTHON=../ports/unix/build-standard/micropython ./run-tests.py -i string_format) | cat
: '>>>>> End Test Output'
rm -f tests/basics/string_format_intbig.py
