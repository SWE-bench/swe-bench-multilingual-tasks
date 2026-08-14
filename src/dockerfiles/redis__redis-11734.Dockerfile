
FROM --platform=linux/amd64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Uncomment deb-src lines. Only works on Ubuntu 22.04 and below
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list

# Includes dependencies for all C/C++ projects
RUN apt update && \
    apt install -y wget git build-essential libtool automake autoconf tcl bison flex cmake python3 python3-pip python3-venv python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_93b552784fdb
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/redis/redis /testbed
cd /testbed
git reset --hard 45d3310694406fb0f338f7c639cda9754edb88f8
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 45d3310694406fb0f338f7c639cda9754edb88f8)
TARGET_EPOCH=$(git show -s --format=%ct 45d3310694406fb0f338f7c639cda9754edb88f8)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
chmod -R 777 /testbed
cd - || true
cd /testbed
make distclean
make
EOF_93b552784fdb


WORKDIR /testbed
