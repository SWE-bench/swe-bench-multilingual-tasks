
FROM --platform=linux/amd64 maven:3.9.12-eclipse-temurin-11-noble

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
ant \
unzip \
&& rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o mvnd.zip https://downloads.apache.org/maven/mvnd/1.0.2/maven-mvnd-1.0.2-linux-amd64.zip && \
    unzip mvnd.zip -d /tmp && \
    mv /tmp/maven-mvnd-1.0.2-linux-amd64 /usr/local/mvnd && \
    rm mvnd.zip && \
    rm -rf /tmp/maven-mvnd-1.0.2-linux-amd64

ENV MVND_HOME=/usr/local/mvnd
ENV PATH=$MVND_HOME/bin:$PATH

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_72b019a607d3
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/apache/druid /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 483a03f26c7221f10493d86715985a58e61af967
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 483a03f26c7221f10493d86715985a58e61af967)
TARGET_EPOCH=$(git show -s --format=%ct 483a03f26c7221f10493d86715985a58e61af967)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
mvn clean install -B -pl server -DskipTests -am
EOF_72b019a607d3


WORKDIR /testbed
