
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

RUN <<EOF_93670a7e86bd
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/fastlane/fastlane /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 65db20a25897595169cb64d7e0900b8176aa62c3
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 65db20a25897595169cb64d7e0900b8176aa62c3)
TARGET_EPOCH=$(git show -s --format=%ct 65db20a25897595169cb64d7e0900b8176aa62c3)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
bundle install --jobs=$(nproc)
EOF_93670a7e86bd


WORKDIR /testbed
