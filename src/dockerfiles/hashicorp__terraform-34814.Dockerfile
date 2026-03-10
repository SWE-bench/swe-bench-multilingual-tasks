
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
			url='https://dl.google.com/go/go1.22.12.linux-amd64.tar.gz'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.12.linux-armv6l.tar.gz'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.22.12.linux-arm64.tar.gz'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.22.12.linux-386.tar.gz'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.22.12.linux-mips64le.tar.gz'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.22.12.linux-ppc64le.tar.gz'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.12.linux-riscv64.tar.gz'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.12.linux-s390x.tar.gz'; \
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

RUN <<EOF_3e8a26e6e3d7
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/hashicorp/terraform /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 310331bdc6b747b68b2e2dd6be257dfc78677973
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 310331bdc6b747b68b2e2dd6be257dfc78677973)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || echo "WARNING: $COMMIT_COUNT commits found after base_commit (expected 0, non-fatal)"
cd - || true
cd /testbed
go test -c ./internal/builtin/provisioners/remote-exec
EOF_3e8a26e6e3d7


WORKDIR /testbed
