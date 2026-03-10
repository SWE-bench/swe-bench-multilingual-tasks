
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

RUN <<EOF_f7c50b1a114b
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/jqlang/jq /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard f86566b2631b777c0d0c9a4572eb21146a14829b
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci f86566b2631b777c0d0c9a4572eb21146a14829b)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || echo "WARNING: $COMMIT_COUNT commits found after base_commit (expected 0, non-fatal)"
cd - || true
cd /testbed
git submodule update --init
autoreconf -fi
./configure --with-oniguruma=builtin
make clean
touch src/parser.y src/lexer.l
make -j$(nproc)
EOF_f7c50b1a114b


WORKDIR /testbed
