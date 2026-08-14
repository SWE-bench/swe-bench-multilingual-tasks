
FROM --platform=linux/amd64 rust:1.81

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
&& rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_2c5d5b4b99e9
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/sharkdp/bat /testbed
cd /testbed
git reset --hard 59d4cfb75c1a17a26b2b38956ee08d8c53f04e04
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 59d4cfb75c1a17a26b2b38956ee08d8c53f04e04)
TARGET_EPOCH=$(git show -s --format=%ct 59d4cfb75c1a17a26b2b38956ee08d8c53f04e04)
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
RUSTFLAGS=-Awarnings cargo test --package bat --test integration_tests ignored_suffix_arg --no-run
EOF_2c5d5b4b99e9


WORKDIR /testbed
