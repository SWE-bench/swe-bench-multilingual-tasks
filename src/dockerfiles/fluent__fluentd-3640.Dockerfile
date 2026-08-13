
FROM --platform=linux/amd64 ruby:3.3.8-bookworm

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

RUN <<EOF_6e90843fb66a
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/fluent/fluentd /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 8ced42ce86edf5a5c73e009cfd093e6c3fcc7e2d
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 8ced42ce86edf5a5c73e009cfd093e6c3fcc7e2d)
TARGET_EPOCH=$(git show -s --format=%ct 8ced42ce86edf5a5c73e009cfd093e6c3fcc7e2d)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
bundle install
EOF_6e90843fb66a


WORKDIR /testbed
