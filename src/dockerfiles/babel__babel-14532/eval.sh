#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
echo "No test files to reset"
git apply --verbose --reject - <<'EOF_ab2291ad51ad'
diff --git a/packages/babel-generator/test/fixtures/parentheses/unary-postfix/input.js b/packages/babel-generator/test/fixtures/parentheses/unary-postfix/input.js
new file mode 100644
index 000000000000..1603497b5d89
--- /dev/null
+++ b/packages/babel-generator/test/fixtures/parentheses/unary-postfix/input.js
@@ -0,0 +1,1 @@
+(function () { return {x: 24} }()).x++;
diff --git a/packages/babel-generator/test/fixtures/parentheses/unary-postfix/output.js b/packages/babel-generator/test/fixtures/parentheses/unary-postfix/output.js
new file mode 100644
index 000000000000..f07a72eed6f8
--- /dev/null
+++ b/packages/babel-generator/test/fixtures/parentheses/unary-postfix/output.js
@@ -0,0 +1,5 @@
+(function () {
+  return {
+    x: 24
+  };
+})().x++;
\ No newline at end of file

EOF_ab2291ad51ad
make build
: '>>>>> Start Test Output'
yarn jest babel-generator --verbose
: '>>>>> End Test Output'
echo "No test files to reset"
