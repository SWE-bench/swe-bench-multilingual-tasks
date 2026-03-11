
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

RUN <<EOF_d897bcb42d91
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/redis/redis /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard df327b8bd56023931cd41e233f8703de7bbaa82c
git remote remove origin
git branch | grep -v '^\*' | xargs -r git branch -D || true
git tag -l | xargs -r git tag -d
TARGET_TIMESTAMP=$(git show -s --format=%ci df327b8bd56023931cd41e233f8703de7bbaa82c)
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
make distclean
make
EOF_d897bcb42d91


WORKDIR /testbed
