#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
git status
git show
git -c core.fileMode=false diff 0589b1475d56b0b541348aa56f201ec7c56c56d5
git checkout 0589b1475d56b0b541348aa56f201ec7c56c56d5 packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts
git apply -v - <<'EOF_114329324912'
diff --git a/packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts b/packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts
index 734baea200bd..016f89688faa 100644
--- a/packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts
+++ b/packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts
@@ -1166,6 +1166,37 @@ describe('unwrapMdxCodeBlocks', () => {
     `);
   });
 
+  it('can unwrap a simple mdx code block with CRLF', () => {
+    // Note: looks like string dedent mess up with \r
+    expect(
+      unwrapMdxCodeBlocks(`
+# Title\r
+\`\`\`mdx-code-block\r
+import Comp, {User} from "@site/components/comp"\r
+\r
+<Comp prop="test">\r
+  <User user={{firstName: "Sébastien"}} />\r
+</Comp>\r
+\r
+export const age = 36\r
+\`\`\`\r
+\r
+text\r
+`),
+    ).toBe(`
+# Title\r
+import Comp, {User} from "@site/components/comp"\r
+\r
+<Comp prop="test">\r
+  <User user={{firstName: "Sébastien"}} />\r
+</Comp>\r
+\r
+export const age = 36\r
+\r
+text\r
+`);
+  });
+
   it('can unwrap a nested mdx code block', () => {
     expect(
       unwrapMdxCodeBlocks(dedent`

EOF_114329324912
: '>>>>> Start Test Output'
(yarn test packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts --verbose) | cat
: '>>>>> End Test Output'
git checkout 0589b1475d56b0b541348aa56f201ec7c56c56d5 packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts
