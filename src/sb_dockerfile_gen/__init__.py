import importlib.resources as resources
import json
import re
from argparse import ArgumentParser
from pathlib import Path

from sb_dockerfile_gen.c import (
    _DOCKERFILE_BASE_C,
    MAP_REPO_VERSION_TO_SPECS_C,
)
from sb_dockerfile_gen.go import (
    _DOCKERFILE_BASE_GO,
    MAP_REPO_VERSION_TO_SPECS_GO,
)
from sb_dockerfile_gen.java import (
    _DOCKERFILE_BASE_JAVA,
    MAP_REPO_VERSION_TO_SPECS_JAVA,
)
from sb_dockerfile_gen.javascript import (
    _DOCKERFILE_BASE_JS,
    MAP_REPO_VERSION_TO_SPECS_JS,
)
from sb_dockerfile_gen.php import (
    _DOCKERFILE_BASE_PHP,
    MAP_REPO_VERSION_TO_SPECS_PHP,
)
from sb_dockerfile_gen.ruby import (
    _DOCKERFILE_BASE_RUBY,
    MAP_REPO_VERSION_TO_SPECS_RUBY,
)
from sb_dockerfile_gen.rust import (
    _DOCKERFILE_BASE_RUST,
    MAP_REPO_VERSION_TO_SPECS_RUST,
)
from sb_dockerfile_gen.constants import (
    CONTAINER_ENV_NAME,
    CONTAINER_WORKDIR,
    END_TEST_OUTPUT,
    START_TEST_OUTPUT,
    INSTANCE_OVERRIDES,
)
import sb_dockerfile_gen.fixtures
from sb_dockerfile_gen.utils import (
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
    fixture_path = resources.files(sb_dockerfile_gen.fixtures) / fixture_name
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


def load_instances(
    dataset_name_or_path: str,
    split: str = "test",
    instance_ids: list[str] | None = None,
):
    """Load instances from HuggingFace dataset name or local JSON/JSONL file."""
    path = Path(dataset_name_or_path)
    if path.exists() and path.is_file():
        if path.suffix == ".parquet":
            import pandas as pd
            instances = pd.read_parquet(path).to_dict(orient="records")
        elif path.suffix == ".jsonl":
            with open(path) as f:
                instances = [json.loads(line) for line in f if line.strip()]
        else:
            with open(path) as f:
                instances = json.load(f)
            if isinstance(instances, dict):
                instances = list(instances.values())
        if instance_ids:
            instance_ids_set = set(instance_ids)
            instances = [
                i for i in instances if i["instance_id"] in instance_ids_set
            ]
        return instances
    # Fall back to HuggingFace (optional dependency)
    from swebench.harness.utils import load_swebench_dataset

    return load_swebench_dataset(
        dataset_name_or_path, split, instance_ids=instance_ids
    )


def generate_instances(
    dataset_name_or_path: str,
    split: str = "test",
    output_dir: str = "src/instances",
    instance_ids: list[str] | None = None,
):
    """Generate Dockerfiles for each instance."""
    instances = load_instances(dataset_name_or_path, split, instance_ids)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    for instance in instances:
        dockerfile_path = output_path / f"{instance['instance_id']}.Dockerfile"
        dockerfile_path.write_text(_get_dockerfile(instance))

    print(f"Generated {len(instances)} Dockerfiles in {output_path}")


def main():
    parser = ArgumentParser(
        description="Generate Dockerfiles for SWE-bench Multilingual benchmarks"
    )
    parser.add_argument(
        "dataset",
        help="HuggingFace dataset name or path to local JSON/JSONL file",
    )
    parser.add_argument("--split", default="test")
    parser.add_argument("--output_dir", default="src/instances")
    parser.add_argument("--instance_ids", nargs="+", default=None)
    args = parser.parse_args()
    generate_instances(args.dataset, args.split, args.output_dir, args.instance_ids)


if __name__ == "__main__":
    main()
