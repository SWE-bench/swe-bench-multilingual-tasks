#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git checkout ab53bf0c4727ae63c6a3a3d772b7bd837d2f49c3 tokio-util/tests/time_delay_queue.rs
git apply --verbose --reject - <<'EOF_a38e30f35035'
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

EOF_a38e30f35035
: '>>>>> Start Test Output'
cargo test --test time_delay_queue --no-fail-fast
: '>>>>> End Test Output'
git checkout ab53bf0c4727ae63c6a3a3d772b7bd837d2f49c3 tokio-util/tests/time_delay_queue.rs
