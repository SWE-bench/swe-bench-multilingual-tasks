
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

RUN <<EOF_a32ec9d9b6c3
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/fluent/fluentd /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard c0f1db966a2809a13de217b0ec0adc9a29decc79
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci c0f1db966a2809a13de217b0ec0adc9a29decc79)
git branch | grep -v '^\*' | xargs -r git branch -D || true
git tag -l | xargs -r git tag -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
bundle install
EOF_a32ec9d9b6c3


WORKDIR /testbed
