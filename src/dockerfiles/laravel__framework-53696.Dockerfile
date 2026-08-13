
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

RUN <<EOF_060fe9e550de
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/laravel/framework /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 9ec9479e8e10d766eeeb85a3bdd451a505abf8ec
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 9ec9479e8e10d766eeeb85a3bdd451a505abf8ec)
TARGET_EPOCH=$(git show -s --format=%ct 9ec9479e8e10d766eeeb85a3bdd451a505abf8ec)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
git checkout -B master
rm -f composer.lock
composer install
EOF_060fe9e550de


WORKDIR /testbed
