
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

RUN curl -sS https://getcomposer.org/installer | php -- --2.2 --install-dir=/usr/local/bin --filename=composer

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_376cadd2b2f3
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/php-cs-fixer/php-cs-fixer /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 10fb65e3e8b8645f74f6ab099dfa11ce5ac5cfcd
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 10fb65e3e8b8645f74f6ab099dfa11ce5ac5cfcd)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || echo "WARNING: $COMMIT_COUNT commits found after base_commit (expected 0, non-fatal)"
cd - || true
cd /testbed
composer update
composer install
EOF_376cadd2b2f3


WORKDIR /testbed
