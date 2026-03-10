
FROM --platform=linux/amd64 rust:1.81

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
&& rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_df5d7f9bda62
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/uutils/coreutils /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard af86aee6b86a99736ca304ff656d0e4c6d547333
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci af86aee6b86a99736ca304ff656d0e4c6d547333)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || echo "WARNING: $COMMIT_COUNT commits found after base_commit (expected 0, non-fatal)"
cd - || true
cd /testbed
cargo test --no-run -- test_cp_cp test_cp_same_file test_cp_multiple_files test_cp_single_file test_cp_no_file
EOF_df5d7f9bda62


WORKDIR /testbed
