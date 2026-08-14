import importlib.resources as resources
import json
import re
from argparse import ArgumentParser
from pathlib import Path

from .c import (
    _DOCKERFILE_BASE_C,
    MAP_REPO_VERSION_TO_SPECS_C,
)
from .go import (
    _DOCKERFILE_BASE_GO,
    MAP_REPO_VERSION_TO_SPECS_GO,
)
from .java import (
    _DOCKERFILE_BASE_JAVA,
    MAP_REPO_VERSION_TO_SPECS_JAVA,
)
from .javascript import (
    _DOCKERFILE_BASE_JS,
    MAP_REPO_VERSION_TO_SPECS_JS,
)
from .php import (
    _DOCKERFILE_BASE_PHP,
    MAP_REPO_VERSION_TO_SPECS_PHP,
)
from .ruby import (
    _DOCKERFILE_BASE_RUBY,
    MAP_REPO_VERSION_TO_SPECS_RUBY,
)
from .rust import (
    _DOCKERFILE_BASE_RUST,
    MAP_REPO_VERSION_TO_SPECS_RUST,
)
from .constants import (
    CONTAINER_ENV_NAME,
    CONTAINER_WORKDIR,
    END_TEST_OUTPUT,
    START_TEST_OUTPUT,
    INSTANCE_OVERRIDES,
)
from . import fixtures
from .utils import (
    generate_heredoc_delimiter,
    git_clone_timesafe,
    make_heredoc_run_command,
)

MAP_REPO_VERSION_TO_SPECS = {
    **MAP_REPO_VERSION_TO_SPECS_C,
    **MAP_REPO_VERSION_TO_SPECS_GO,
    **MAP_REPO_VERSION_TO_SPECS_JAVA,
    **MAP_REPO_VERSION_TO_SPECS_JS,
    **MAP_REPO_VERSION_TO_SPECS_PHP,
    **MAP_REPO_VERSION_TO_SPECS_RUBY,
    **MAP_REPO_VERSION_TO_SPECS_RUST,
}


# ── Dockerfile generation ──────────────────────────────────────────────


def get_dockerfile_base(instance, docker_specs):
    if instance["repo"] in MAP_REPO_VERSION_TO_SPECS_C:
        return _DOCKERFILE_BASE_C.format(**docker_specs)
    elif instance["repo"] in MAP_REPO_VERSION_TO_SPECS_GO:
        return _DOCKERFILE_BASE_GO.format(**docker_specs)
    elif instance["repo"] in MAP_REPO_VERSION_TO_SPECS_JAVA:
        return _DOCKERFILE_BASE_JAVA.format(**docker_specs)
    elif instance["repo"] in MAP_REPO_VERSION_TO_SPECS_JS:
        return _DOCKERFILE_BASE_JS.format(**docker_specs)
    elif instance["repo"] in MAP_REPO_VERSION_TO_SPECS_PHP:
        return _DOCKERFILE_BASE_PHP.format(**docker_specs)
    elif instance["repo"] in MAP_REPO_VERSION_TO_SPECS_RUBY:
        return _DOCKERFILE_BASE_RUBY.format(**docker_specs)
    elif instance["repo"] in MAP_REPO_VERSION_TO_SPECS_RUST:
        return _DOCKERFILE_BASE_RUST.format(**docker_specs)
    else:
        raise ValueError(f"Invalid repository for multilingual: {instance['repo']}")


def _load_fixture(fixture_name: str) -> str:
    """Load a fixture file."""
    fixture_path = resources.files(fixtures) / fixture_name
    return fixture_path.read_text()


def _load_cargo_lock(fixture_name: str) -> str:
    """Load a Cargo.lock fixture file."""
    return _load_fixture(fixture_name)


def make_repo_script_list(specs, repo, base_commit) -> list:
    setup_commands = [
        *git_clone_timesafe(repo, base_commit, CONTAINER_WORKDIR),
        f"cd {CONTAINER_WORKDIR}",
    ]
    if "cargo_lock" in specs:
        lock_content = _load_cargo_lock(specs["cargo_lock"])
        delimiter = generate_heredoc_delimiter(lock_content)
        setup_commands.append(
            f"cat <<'{delimiter}' > Cargo.lock\n{lock_content}{delimiter}"
        )
    if "pre_install" in specs:
        setup_commands.extend(specs["pre_install"])
    if "composer_json" in specs:
        json_content = _load_fixture(specs["composer_json"])
        delimiter = generate_heredoc_delimiter(json_content)
        setup_commands.append(
            f"cat <<'{delimiter}' > composer.json\n{json_content}{delimiter}"
        )
    if "composer_lock" in specs:
        lock_content = _load_fixture(specs["composer_lock"])
        delimiter = generate_heredoc_delimiter(lock_content)
        setup_commands.append(
            f"cat <<'{delimiter}' > composer.lock\n{lock_content}{delimiter}"
        )
    if "install" in specs:
        setup_commands.extend(specs["install"])
    if "build" in specs:
        setup_commands.extend(specs["build"])
    if "post_build_cleanup" in specs:
        setup_commands.extend(specs["post_build_cleanup"])
    return setup_commands


def make_env_script_list(specs) -> list:
    reqs_commands = []
    if "apt-pkgs" in specs:
        reqs_commands += [
            "apt-get update",
            f"apt-get install -y {' '.join(specs['apt-pkgs'])}",
        ]
    return reqs_commands


def _get_dockerfile(instance) -> str:
    repo = instance["repo"]
    version = instance.get("version")
    base_commit = instance["base_commit"]
    specs = MAP_REPO_VERSION_TO_SPECS[repo][version]
    docker_specs = specs.get("docker_specs", {})
    env_script = make_env_script_list(specs)
    repo_script = make_repo_script_list(specs, repo, base_commit)
    monolithic_dockerfile = get_dockerfile_base(instance, docker_specs)
    if env_script:
        monolithic_dockerfile += f"\n{make_heredoc_run_command(env_script)}\n"
    monolithic_dockerfile += f'\nRUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate {CONTAINER_ENV_NAME}" > /root/.bashrc\n'
    if repo_script:
        monolithic_dockerfile += f"\n{make_heredoc_run_command(repo_script)}\n"
    monolithic_dockerfile += f"\nWORKDIR {CONTAINER_WORKDIR}\n"
    return monolithic_dockerfile


# ── Eval script generation ─────────────────────────────────────────────


def _get_eval_script(instance: dict) -> str:
    """Generate the eval.sh script for a multilingual instance."""
    repo = instance["repo"]
    version = instance.get("version")
    base_commit = instance["base_commit"]
    test_patch = instance["test_patch"]
    specs = MAP_REPO_VERSION_TO_SPECS[repo][version]

    # Files modified by the test patch – use a/ side for reset so renames work
    test_files_old = re.findall(r"diff --git a/(.*) b/.*", test_patch)
    # files the test patch creates do not exist at base_commit, so `git checkout`
    # fails on them with a pathspec error and the tests never run
    _lines = test_patch.split("\n")
    _new = set()
    for _i, _l in enumerate(_lines):
        if "new file mode" in _l:
            for _j in range(max(0, _i - 3), _i):
                _m = re.match(r"diff --git a/(.*) b/.*", _lines[_j])
                if _m:
                    _new.add(_m.group(1))
    _existing = [f for f in test_files_old if f not in _new]
    _created = [f for f in test_files_old if f in _new]
    _reset = []
    if _existing:
        _reset.append(f"git checkout {base_commit} {' '.join(_existing)}")
    if _created:
        _reset.append(f"rm -f {' '.join(_created)}")
    reset_tests_command = " && ".join(_reset) if _reset else "true"

    HEREDOC_DELIMITER = "EOF_114329324912"
    apply_test_patch_command = (
        f"git apply -v - <<'{HEREDOC_DELIMITER}'\n{test_patch}\n{HEREDOC_DELIMITER}"
    )

    # test_cmd is a list for multilingual
    test_cmd = specs["test_cmd"]
    if isinstance(test_cmd, list):
        test_command = " && ".join(test_cmd)
    else:
        test_command = test_cmd

    eval_commands = [
        "#!/bin/bash",
        "set -uxo pipefail",
        f"cd {CONTAINER_WORKDIR}",
        f"git config --global --add safe.directory {CONTAINER_WORKDIR}",
        "git status",
        "git show",
        f"git -c core.fileMode=false diff {base_commit}",
        reset_tests_command,
        apply_test_patch_command,
    ]
    if "build" in specs:
        eval_commands.extend(specs["build"])
    eval_commands += [
        *(
            [
                # xtrace off, or the trace echoes the marker text a second time and
                # the harness splits on the wrong occurrence
                "{ set +x; } 2>/dev/null",
                f"echo '{START_TEST_OUTPUT}'",
                f"({test_command}) 2>/tmp/swebench_test_stderr.log | cat",
                f"echo '{END_TEST_OUTPUT}'",
                "cat /tmp/swebench_test_stderr.log >&2 || true",
                "set -x",
            ]
            if INSTANCE_OVERRIDES.get(instance["instance_id"], {}).get("isolate_streams")
            else [
                f": '{START_TEST_OUTPUT}'",
                f"({test_command}) | cat",
                f": '{END_TEST_OUTPUT}'",
            ]
        ),
        reset_tests_command,
    ]
    return "\n".join(eval_commands) + "\n"


# ── CLI ────────────────────────────────────────────────────────────────


def regenerate(instance_ids: list[str] | None = None) -> int:
    """Rewrite Dockerfile and eval.sh for each task, from its task.json."""
    from .tasks import load_task, task_dirs, write_generated

    wanted = set(instance_ids or [])
    count = 0
    for task_dir in task_dirs():
        if wanted and task_dir.name not in wanted:
            continue
        instance = load_task(task_dir)
        write_generated(task_dir, _get_dockerfile(instance), _get_eval_script(instance))
        count += 1
    return count


def main():
    parser = ArgumentParser(
        description="Regenerate Dockerfile and eval.sh for SWE-bench Multilingual tasks"
    )
    parser.add_argument("--instance_ids", nargs="+", default=None)
    args = parser.parse_args()
    print(f"regenerated {regenerate(args.instance_ids)} tasks")


if __name__ == "__main__":
    main()
