#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
git status
git show
git -c core.fileMode=false diff ab53bf0c4727ae63c6a3a3d772b7bd837d2f49c3
git checkout ab53bf0c4727ae63c6a3a3d772b7bd837d2f49c3 tokio-util/tests/time_delay_queue.rs
git apply -v - <<'EOF_114329324912'
diff --git a/tokio-util/tests/time_delay_queue.rs b/tokio-util/tests/time_delay_queue.rs
index 6616327d41c..9915b11b58a 100644
--- a/tokio-util/tests/time_delay_queue.rs
+++ b/tokio-util/tests/time_delay_queue.rs
@@ -880,6 +880,19 @@ async fn peek() {
     assert!(queue.peek().is_none());
 }
 
+#[tokio::test(start_paused = true)]
+async fn wake_after_remove_last() {
+    let mut queue = task::spawn(DelayQueue::new());
+    let key = queue.insert("foo", ms(1000));
+
+    assert_pending!(poll!(queue));
+
+    queue.remove(&key);
+
+    assert!(queue.is_woken());
+    assert!(assert_ready!(poll!(queue)).is_none());
+}
+
 fn ms(n: u64) -> Duration {
     Duration::from_millis(n)
 }

EOF_114329324912
: '>>>>> Start Test Output'
(cargo test --test time_delay_queue --no-fail-fast) | cat
: '>>>>> End Test Output'
git checkout ab53bf0c4727ae63c6a3a3d772b7bd837d2f49c3 tokio-util/tests/time_delay_queue.rs
