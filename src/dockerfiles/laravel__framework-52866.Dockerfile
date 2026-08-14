
FROM --platform=linux/amd64 php:8.3.16

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    libgd-dev \
    libzip-dev \
    libgmp-dev \
    libftp-dev \
    libcurl4-openssl-dev \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install gd zip gmp ftp curl pcntl

RUN curl -sS https://getcomposer.org/installer | php -- --version=2.8.5 --install-dir=/usr/local/bin --filename=composer

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_162a88de8da4
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/laravel/framework /testbed
cd /testbed
git reset --hard 4c7850844e218b4fa25e29c83bc80b7ef06836cb
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 4c7850844e218b4fa25e29c83bc80b7ef06836cb)
TARGET_EPOCH=$(git show -s --format=%ct 4c7850844e218b4fa25e29c83bc80b7ef06836cb)
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
git checkout -B master
rm -f composer.lock
composer install
EOF_162a88de8da4


WORKDIR /testbed
