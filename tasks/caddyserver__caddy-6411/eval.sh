#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
git status
git show
git -c core.fileMode=false diff 59cbb2c83a03b6fe352ae0b5d05581d9148a4d24
git checkout 59cbb2c83a03b6fe352ae0b5d05581d9148a4d24 replacer_test.go && rm -f caddytest/integration/testdata/foo_with_multiple_trailing_newlines.txt caddytest/integration/testdata/foo_with_trailing_newline.txt
git apply -v - <<'EOF_114329324912'
diff --git a/caddytest/integration/testdata/foo_with_multiple_trailing_newlines.txt b/caddytest/integration/testdata/foo_with_multiple_trailing_newlines.txt
new file mode 100644
index 00000000000..75d7bfb873a
--- /dev/null
+++ b/caddytest/integration/testdata/foo_with_multiple_trailing_newlines.txt
@@ -0,0 +1,2 @@
+foo
+
diff --git a/caddytest/integration/testdata/foo_with_trailing_newline.txt b/caddytest/integration/testdata/foo_with_trailing_newline.txt
new file mode 100644
index 00000000000..257cc5642cb
--- /dev/null
+++ b/caddytest/integration/testdata/foo_with_trailing_newline.txt
@@ -0,0 +1,1 @@
+foo
diff --git a/replacer_test.go b/replacer_test.go
index cf4d321b6ed..1c1a7048f33 100644
--- a/replacer_test.go
+++ b/replacer_test.go
@@ -431,6 +431,14 @@ func TestReplacerNew(t *testing.T) {
 			variable: "file.caddytest/integration/testdata/foo.txt",
 			value:    "foo",
 		},
+		{
+			variable: "file.caddytest/integration/testdata/foo_with_trailing_newline.txt",
+			value:    "foo",
+		},
+		{
+			variable: "file.caddytest/integration/testdata/foo_with_multiple_trailing_newlines.txt",
+			value:    "foo" + getEOL(),
+		},
 	} {
 		if val, ok := repl.providers[1].replace(tc.variable); ok {
 			if val != tc.value {
@@ -442,6 +450,13 @@ func TestReplacerNew(t *testing.T) {
 	}
 }
 
+func getEOL() string {
+	if os.PathSeparator == '\\' {
+		return "\r\n" // Windows EOL
+	}
+	return "\n" // Unix and modern macOS EOL
+}
+
 func TestReplacerNewWithoutFile(t *testing.T) {
 	repl := NewReplacer().WithoutFile()
 

EOF_114329324912
: '>>>>> Start Test Output'
(go test -v . -run "TestReplacerNew*") | cat
: '>>>>> End Test Output'
git checkout 59cbb2c83a03b6fe352ae0b5d05581d9148a4d24 replacer_test.go && rm -f caddytest/integration/testdata/foo_with_multiple_trailing_newlines.txt caddytest/integration/testdata/foo_with_trailing_newline.txt
