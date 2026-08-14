#!/bin/bash
set -uxo pipefail
cd /testbed
git config --global --add safe.directory /testbed
git status
git show
git -c core.fileMode=false diff 66cb6a78776b263a2fe4d1283426e699961095d2
git checkout 66cb6a78776b263a2fe4d1283426e699961095d2 hooks/test/browser/errorBoundary.test.js
git apply -v - <<'EOF_114329324912'
diff --git a/hooks/test/browser/errorBoundary.test.js b/hooks/test/browser/errorBoundary.test.js
index 0e7de2f625..415d76cc91 100644
--- a/hooks/test/browser/errorBoundary.test.js
+++ b/hooks/test/browser/errorBoundary.test.js
@@ -1,6 +1,6 @@
-import { createElement, render } from 'preact';
+import { Fragment, createElement, render } from 'preact';
 import { setupScratch, teardown } from '../../../test/_util/helpers';
-import { useErrorBoundary, useLayoutEffect } from 'preact/hooks';
+import { useErrorBoundary, useLayoutEffect, useState } from 'preact/hooks';
 import { setupRerender } from 'preact/test-utils';
 
 /** @jsx createElement */
@@ -152,4 +152,81 @@ describe('errorBoundary', () => {
 		expect(badEffect).to.be.calledOnce;
 		expect(goodEffect).to.be.calledOnce;
 	});
+
+	it('should not duplicate in lists where an item throws and the parent catches and returns a differing type', () => {
+		const baseTodos = [
+			{ text: 'first item', completed: false },
+			{ text: 'Test the feature', completed: false },
+			{ text: 'another item', completed: false }
+		];
+
+		function TodoList() {
+			const [todos, setTodos] = useState([...baseTodos]);
+
+			return (
+				<Fragment>
+					<ul>
+						{todos.map((todo, index) => (
+							<TodoItem
+								key={index}
+								toggleTodo={() => {
+									todos[index] = {
+										...todos[index],
+										completed: !todos[index].completed
+									};
+									setTodos([...todos]);
+								}}
+								todo={todo}
+								index={index}
+							/>
+						))}
+					</ul>
+				</Fragment>
+			);
+		}
+
+		function TodoItem(props) {
+			const [error] = useErrorBoundary();
+
+			if (error) {
+				return <li>An error occurred: {error}</li>;
+			}
+
+			return <TodoItemInner {...props} />;
+		}
+		let set;
+		function TodoItemInner({ todo, index, toggleTodo }) {
+			if (todo.completed) {
+				throw new Error('Todo completed!');
+			}
+
+			if (index === 1) {
+				set = toggleTodo;
+			}
+
+			return (
+				<li>
+					<label>
+						<input
+							type="checkbox"
+							checked={todo.completed}
+							onInput={toggleTodo}
+						/>
+						{todo.completed ? <s>{todo.text}</s> : todo.text}
+					</label>
+				</li>
+			);
+		}
+
+		render(<TodoList />, scratch);
+		expect(scratch.innerHTML).to.equal(
+			'<ul><li><label><input type="checkbox">first item</label></li><li><label><input type="checkbox">Test the feature</label></li><li><label><input type="checkbox">another item</label></li></ul>'
+		);
+
+		set();
+		rerender();
+		expect(scratch.innerHTML).to.equal(
+			'<ul><li><label><input type="checkbox">first item</label></li><li>An error occurred: </li><li><label><input type="checkbox">another item</label></li></ul>'
+		);
+	});
 });

EOF_114329324912
: '>>>>> Start Test Output'
(COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/errorBoundary.test.js") | cat
: '>>>>> End Test Output'
git checkout 66cb6a78776b263a2fe4d1283426e699961095d2 hooks/test/browser/errorBoundary.test.js
