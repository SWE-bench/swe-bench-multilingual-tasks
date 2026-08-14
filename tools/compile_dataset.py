"""Rebuild the dataset rows from the tasks/ tree, with no help from HuggingFace."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from dockerfile_gen.tasks import load_task, task_dirs  # noqa: E402


def compile_dataset() -> list[dict]:
    return [load_task(d) for d in task_dirs()]


if __name__ == "__main__":
    print(f"compiled {len(compile_dataset())} instances from tasks/")
