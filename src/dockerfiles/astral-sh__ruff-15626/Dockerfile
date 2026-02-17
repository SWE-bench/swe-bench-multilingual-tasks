
FROM --platform=linux/amd64 rust:1.84

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
&& rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_a5d4719d6ab3
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/astral-sh/ruff /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 13a6b5600b47489ca6af0b5a13d916bda8e50662
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 13a6b5600b47489ca6af0b5a13d916bda8e50662)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
RUSTFLAGS=-Awarnings cargo test --package ruff_linter --lib rules::flake8_simplify::tests --no-run
EOF_a5d4719d6ab3


WORKDIR /testbed
