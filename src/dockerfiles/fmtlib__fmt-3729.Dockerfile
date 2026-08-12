
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

RUN <<EOF_1a20484fba1f
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/fmtlib/fmt /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 5cfd28d476c6859617878f951931b8ce7d36b9df
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 5cfd28d476c6859617878f951931b8ce7d36b9df)
git branch | grep -v '^\*' | xargs -r git branch -D || true
git tag -l | xargs -r git tag -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
mkdir -p build
cmake -B build -S .
cmake --build build --parallel $(nproc) --target std-test
EOF_1a20484fba1f


WORKDIR /testbed
