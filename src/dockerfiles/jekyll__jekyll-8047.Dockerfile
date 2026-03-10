
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

RUN <<EOF_d3213a063c73
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/jekyll/jekyll /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard ab6ef0b257e4c7aafec0518d93bea3e9c4b75b75
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci ab6ef0b257e4c7aafec0518d93bea3e9c4b75b75)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
sed -i '/^[[:space:]]*install_if.*mingw/,/^[[:space:]]*end/d' Gemfile
script/bootstrap
bundle add webrick
EOF_d3213a063c73


WORKDIR /testbed
