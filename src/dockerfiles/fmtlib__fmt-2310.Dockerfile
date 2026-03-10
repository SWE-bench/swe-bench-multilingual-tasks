
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

RUN <<EOF_b1c2d63173fc
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/fmtlib/fmt /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 7612f18dc8e0112e64e0845a1ebe9da6cfb8a123
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 7612f18dc8e0112e64e0845a1ebe9da6cfb8a123)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
mkdir -p build
cmake -B build -S .
cmake --build build --parallel $(nproc) --target format-test
EOF_b1c2d63173fc


WORKDIR /testbed
