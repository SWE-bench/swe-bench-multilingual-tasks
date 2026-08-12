
FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
wget \
git \
build-essential \
&& rm -rf /var/lib/apt/lists/*

# Install go. Based on https://github.com/docker-library/golang/blob/7ba64590f6cd1268b3604329ac28e5fd7400ca79/1.24/bookworm/Dockerfile
RUN set -eux; \
	now="$(date '+%s')"; \
	arch="$(dpkg --print-architecture)"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.23.8.linux-amd64.tar.gz'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.23.8.linux-armv6l.tar.gz'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.23.8.linux-arm64.tar.gz'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.23.8.linux-386.tar.gz'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.23.8.linux-mips64le.tar.gz'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.23.8.linux-ppc64le.tar.gz'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.23.8.linux-riscv64.tar.gz'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.23.8.linux-s390x.tar.gz'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	\
	wget -O go.tgz "$url" --progress=dot:giga; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz;
ENV PATH=/usr/local/go/bin:$PATH
RUN go version

RUN adduser --disabled-password --gecos 'dog' nonroot

RUN echo "source /opt/miniconda3/etc/profile.d/conda.sh && conda activate testbed" > /root/.bashrc

RUN <<EOF_fb8da4f8f8b3
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/gin-gonic/gin /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard f2bbdfe9f26d84cb994f381050692a9e4553bf75
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci f2bbdfe9f26d84cb994f381050692a9e4553bf75)
git branch | grep -v '^\*' | xargs -r git branch -D || true
git tag -l | xargs -r git tag -d
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
go test -c .
EOF_fb8da4f8f8b3


WORKDIR /testbed
