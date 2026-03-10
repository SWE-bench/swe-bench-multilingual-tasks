
FROM --platform=linux/amd64 rust:1.77

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
&& rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_407de032d3cf
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/nushell/nushell /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 0c5a67f4e5bf17a2fffbe3cbb54792a6464b3237
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 0c5a67f4e5bf17a2fffbe3cbb54792a6464b3237)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
cargo test external_arguments --no-run
EOF_407de032d3cf


WORKDIR /testbed
