
FROM --platform=linux/amd64 ruby:3.3

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
jq \
&& rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_881e0201b02c
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/jekyll/jekyll /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard bb851e235dfbe1f197388aea3e7f0eeb1b50c4e3
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci bb851e235dfbe1f197388aea3e7f0eeb1b50c4e3)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
script/bootstrap
EOF_881e0201b02c


WORKDIR /testbed
