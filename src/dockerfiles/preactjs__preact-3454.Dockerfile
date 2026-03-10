
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
RUN bash -c "set -eo pipefail && curl -fsSL https://deb.nodesource.com/setup_18.x | bash -"
RUN apt-get update && apt-get install -y nodejs
RUN node -v && npm -v

# Install pnpm
RUN npm install --global corepack@latest
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

RUN <<EOF_4c5030293b5d
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/preactjs/preact /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 00c8d1ff1498084c15408cf0014d4c7facdb5dd7
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 00c8d1ff1498084c15408cf0014d4c7facdb5dd7)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || echo "WARNING: $COMMIT_COUNT commits found after base_commit (expected 0, non-fatal)"
cd - || true
cd /testbed
npm install
EOF_4c5030293b5d


WORKDIR /testbed
