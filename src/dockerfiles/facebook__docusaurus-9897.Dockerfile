
FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
    wget \
    curl \
    git \
    build-essential \
    jq \
    gnupg \
    ca-certificates \
    apt-transport-https

# Install node
RUN bash -c "set -eo pipefail && curl -fsSL https://deb.nodesource.com/setup_20.x | bash -"
RUN apt-get update && apt-get install -y nodejs
RUN node -v && npm -v

# Install pnpm
RUN npm install --global corepack@0.32.0
RUN corepack enable pnpm

# Install Chrome for browser testing
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Set up Chrome environment variables
ENV CHROME_BIN /usr/bin/google-chrome
ENV CHROME_PATH /usr/bin/google-chrome

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_01f846d90348
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/facebook/docusaurus /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 0589b1475d56b0b541348aa56f201ec7c56c56d5
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 0589b1475d56b0b541348aa56f201ec7c56c56d5)
TARGET_EPOCH=$(git show -s --format=%ct 0589b1475d56b0b541348aa56f201ec7c56c56d5)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
yarn install
EOF_01f846d90348


WORKDIR /testbed
