
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

RUN <<EOF_466827ed2db0
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/sharkdp/bat /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 2b9d25df052e50c60531b1000703b79bf9b6065a
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 2b9d25df052e50c60531b1000703b79bf9b6065a)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
EOF_466827ed2db0


WORKDIR /testbed
