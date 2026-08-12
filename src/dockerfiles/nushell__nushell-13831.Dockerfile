
FROM --platform=linux/amd64 rust:1.79

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
&& rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_956c7af5fe5c
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/nushell/nushell /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard fb34a4fc6c9ca882cc6dc95d437902a45c402e9a
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci fb34a4fc6c9ca882cc6dc95d437902a45c402e9a)
git branch | grep -v '^\*' | xargs -r git branch -D || true
git tag -l | xargs -r git tag -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
cargo test -p nu-command --no-run split_column
cargo build
EOF_956c7af5fe5c


WORKDIR /testbed
