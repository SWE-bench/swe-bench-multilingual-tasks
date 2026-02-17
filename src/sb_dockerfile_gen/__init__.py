import json
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
    FAIL_ONLY_REPOS,
    MAP_REPO_TO_PARSER_NAME,
    START_TEST_OUTPUT,
)
from sb_dockerfile_gen.utils import (
    generate_heredoc_delimiter,
    get_modified_files,
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


def make_repo_script_list(specs, repo, base_commit) -> list:
    setup_commands = [
        *git_clone_timesafe(repo, base_commit, CONTAINER_WORKDIR),
        f"cd {CONTAINER_WORKDIR}",
    ]
    if "pre_install" in specs:
        setup_commands.extend(specs["pre_install"])
    if "install" in specs:
        setup_commands.extend(specs["install"])
    if "build" in specs:
        setup_commands.extend(specs["build"])
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


def _get_eval_script(instance) -> str:
    repo = instance["repo"]
    version = instance.get("version")
    base_commit = instance["base_commit"]
    test_patch = instance["test_patch"]
    specs = MAP_REPO_VERSION_TO_SPECS[repo][version]

    repo_directory = CONTAINER_WORKDIR

    test_files = get_modified_files(test_patch)
    if test_files:
        reset_tests_command = f"git checkout {base_commit} {' '.join(test_files)}"
    else:
        reset_tests_command = 'echo "No test files to reset"'

    build_commands = []
    if "build" in specs:
        build_commands.extend(specs["build"])

    delimiter = generate_heredoc_delimiter(test_patch)
    apply_test_patch_command = (
        f"git apply --verbose --reject - <<'{delimiter}'\n{test_patch}\n{delimiter}"
    )

    test_cmd = specs["test_cmd"]
    test_commands = [test_cmd] if isinstance(test_cmd, str) else test_cmd

    eval_commands = [
        f"cd {repo_directory}",
        f"git config --global --add safe.directory {repo_directory}",
        f"cd {repo_directory}",
        reset_tests_command,
        apply_test_patch_command,
        *build_commands,
        f": '{START_TEST_OUTPUT}'",
        *test_commands,
        f": '{END_TEST_OUTPUT}'",
        reset_tests_command,
    ]

    return "\n".join(["#!/bin/bash", "set -uxo pipefail"] + eval_commands) + "\n"


# ── Metadata generation ────────────────────────────────────────────────


def _get_metadata(instance) -> dict:
    f2p = instance.get("FAIL_TO_PASS", "[]")
    p2p = instance.get("PASS_TO_PASS", "[]")
    return {
        "instance_id": instance["instance_id"],
        "repo": instance["repo"],
        "version": instance.get("version"),
        "log_parser": MAP_REPO_TO_PARSER_NAME[instance["repo"]],
        "eval_type": "fail_only" if instance["repo"] in FAIL_ONLY_REPOS else "pass_and_fail",
        "FAIL_TO_PASS": json.loads(f2p) if isinstance(f2p, str) else f2p,
        "PASS_TO_PASS": json.loads(p2p) if isinstance(p2p, str) else p2p,
    }


# ── CLI ────────────────────────────────────────────────────────────────


def load_instances(
    dataset_name_or_path: str,
    split: str = "test",
    instance_ids: list[str] | None = None,
):
    """Load instances from HuggingFace dataset name or local JSON/JSONL file."""
    path = Path(dataset_name_or_path)
    if path.exists() and path.is_file():
        if path.suffix == ".jsonl":
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
    """Generate Dockerfile, eval.sh, and metadata.json for each instance."""
    instances = load_instances(dataset_name_or_path, split, instance_ids)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    for instance in instances:
        instance_dir = output_path / instance["instance_id"]
        instance_dir.mkdir(parents=True, exist_ok=True)

        (instance_dir / "Dockerfile").write_text(_get_dockerfile(instance))
        (instance_dir / "eval.sh").write_text(_get_eval_script(instance))
        (instance_dir / "metadata.json").write_text(
            json.dumps(_get_metadata(instance), indent=2) + "\n"
        )

    print(f"Generated {len(instances)} instances in {output_path}")


def main():
    parser = ArgumentParser(
        description="Generate Dockerfiles, eval scripts, and metadata for SWE-bench Multilingual benchmarks"
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
