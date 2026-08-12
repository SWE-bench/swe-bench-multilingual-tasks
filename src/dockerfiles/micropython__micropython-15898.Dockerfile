
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

RUN <<EOF_aa563141c5a4
#!/bin/bash
set -euxo pipefail
apt-get update
apt-get install -y libffi-dev pkg-config
EOF_aa563141c5a4


RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_9d253aad49eb
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/micropython/micropython /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard b0ba151102a6c1b2e0e4c419c6482a64677c9b40
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci b0ba151102a6c1b2e0e4c419c6482a64677c9b40)
git branch | grep -v '^\*' | xargs -r git branch -D || true
git tag -l | xargs -r git tag -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
python -m venv .venv
source .venv/bin/activate
source ./tools/ci.sh
ci_unix_build_helper VARIANT=standard
gcc -shared -o tests/ports/unix/ffi_lib.so tests/ports/unix/ffi_lib.c
EOF_9d253aad49eb


WORKDIR /testbed
