# We use a modern version of ubuntu as the base image because old golang images
# can cause problems with agent installations. For eg. old GLIBC versions.
_DOCKERFILE_BASE_GO = r"""
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
			url='https://dl.google.com/go/go{go_version}.linux-amd64.tar.gz'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go{go_version}.linux-armv6l.tar.gz'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go{go_version}.linux-arm64.tar.gz'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go{go_version}.linux-386.tar.gz'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go{go_version}.linux-mips64le.tar.gz'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go{go_version}.linux-ppc64le.tar.gz'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go{go_version}.linux-riscv64.tar.gz'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go{go_version}.linux-s390x.tar.gz'; \
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
"""

# Constants - Task Instance Installation Environment
SPECS_CADDY = {
    "6411": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go mod tidy"],
        "test_cmd": ['go test -v . -run "TestReplacerNew*"'],
    },
    "6345": {
        "docker_specs": {"go_version": "1.23.8"},
        # compile the test binary, which downloads relevant packages. faster than go mod tidy
        "install": ["go test -c ./caddytest/integration"],
        "test_cmd": ["go test -v ./caddytest/integration"],
    },
    "6115": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./modules/caddyhttp/reverseproxy"],
        "test_cmd": ["go test -v ./modules/caddyhttp/reverseproxy"],
    },
    "6051": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./caddyconfig/caddyfile"],
        "test_cmd": ["go test -v ./caddyconfig/caddyfile"],
    },
    "5404": {
        "docker_specs": {"go_version": "1.20.14"},
        "install": ["go test -c ./caddyconfig/caddyfile"],
        "test_cmd": ["go test -v ./caddyconfig/caddyfile"],
    },
    "6370": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./cmd"],
        "test_cmd": ["go test -v ./cmd"],
    },
    "6350": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ['go test -c ./caddytest/integration -run "TestCaddyfileAdapt*"'],
        "test_cmd": ['go test -v ./caddytest/integration -run "TestCaddyfileAdapt*"'],
    },
    "6288": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ['go test -c ./caddytest/integration -run "TestCaddyfileAdapt*"'],
        "test_cmd": ['go test -v ./caddytest/integration -run "TestCaddyfileAdapt*"'],
    },
    "5995": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ['go test -c ./caddytest/integration -run "^TestUriReplace"'],
        "test_cmd": ['go test -v ./caddytest/integration -run "^TestUriReplace"'],
    },
    "4943": {
        "docker_specs": {"go_version": "1.18.10"},
        "install": ["go test -c ./modules/logging"],
        "test_cmd": ["go test -v ./modules/logging"],
    },
    "5626": {
        "docker_specs": {"go_version": "1.19.13"},
        "install": ['go test -c ./caddyconfig/httpcaddyfile -run "Test.*Import"'],
        "test_cmd": ['go test -v ./caddyconfig/httpcaddyfile -run "Test.*Import"'],
    },
    "5761": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ['go test -c ./caddyconfig/caddyfile -run "TestLexer.*"'],
        "test_cmd": ['go test -v ./caddyconfig/caddyfile -run "TestLexer.*"'],
    },
    "5870": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ['go test -c . -run "TestUnsyncedConfigAccess"'],
        "test_cmd": ['go test -v . -run "TestUnsyncedConfigAccess"'],
    },
    "4774": {
        "docker_specs": {"go_version": "1.18.10"},
        "install": ['go test -c ./caddytest/integration -run "TestCaddyfileAdapt*"'],
        "test_cmd": ['go test -v ./caddytest/integration -run "TestCaddyfileAdapt*"'],
    },
}

SPECS_TERRAFORM = {
    "35611": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./internal/terraform"],
        "test_cmd": [
            'go test -v ./internal/terraform -run "^TestContext2Apply_provisioner"'
        ],
    },
    "35543": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./internal/terraform"],
        "test_cmd": ['go test -v ./internal/terraform -run "^TestContext2Plan_import"'],
    },
    "34900": {
        "docker_specs": {"go_version": "1.22.12"},
        "install": ["go test -c ./internal/terraform"],
        "test_cmd": [
            'go test -v ./internal/terraform -run "(^TestContext2Apply|^TestContext2Plan).*[Ss]ensitive"'
        ],
    },
    "34580": {
        "docker_specs": {"go_version": "1.21.13"},
        "install": ["go test -c ./internal/command"],
        "test_cmd": ['go test -v ./internal/command -run "^TestFmt"'],
    },
    "34814": {
        "docker_specs": {"go_version": "1.22.12"},
        "install": ["go test -c ./internal/builtin/provisioners/remote-exec"],
        "test_cmd": ["go test -v ./internal/builtin/provisioners/remote-exec"],
    },
}

SPECS_PROMETHEUS = {
    "14861": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./promql"],
        "test_cmd": ['go test -v ./promql -run "^TestEngine"'],
    },
    "13845": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./promql ./model/labels"],
        "test_cmd": [
            'go test -v ./promql ./model/labels -run "^(TestRangeQuery|TestLabels)"'
        ],
    },
    "12874": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./tsdb"],
        "test_cmd": ['go test -v ./tsdb -run "^TestHead"'],
    },
    "11859": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./tsdb"],
        "test_cmd": ['go test -v ./tsdb -run "^TestSnapshot"'],
    },
    "10720": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./promql"],
        "test_cmd": ['go test -v ./promql -run "^TestEvaluations"'],
    },
    "10633": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./discovery/puppetdb"],
        "test_cmd": [
            'go test -v ./discovery/puppetdb -run "TestPuppetDBRefreshWithParameters"'
        ],
    },
    "9248": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./promql"],
        "test_cmd": ['go test -v ./promql -run "^TestEvaluations"'],
    },
    "15142": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./tsdb"],
        "test_cmd": ['go test -v ./tsdb -run "^TestHead"'],
    },
}

SPECS_HUGO = {
    "12768": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./markup/goldmark/blockquotes/..."],
        "test_cmd": ["go test -v ./markup/goldmark/blockquotes/..."],
    },
    "12579": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./resources/page"],
        "test_cmd": ['go test -v ./resources/page -run "^TestGroupBy"'],
    },
    "12562": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./hugolib/..."],
        "test_cmd": ['go test -v ./hugolib/... -run "^TestGetPage[^/]"'],
    },
    "12448": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./hugolib/..."],
        "test_cmd": ['go test -v ./hugolib/... -run "^TestRebuild"'],
    },
    "12343": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./resources/page/..."],
        "test_cmd": ['go test -v ./resources/page/... -run "^Test.*Permalink"'],
    },
    "12204": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./tpl/tplimpl"],
        "test_cmd": ['go test -v ./tpl/tplimpl -run "^TestEmbedded"'],
    },
    "12171": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./hugolib"],
        "test_cmd": ['go test -v ./hugolib -run "^Test.*Pages"'],
    },
}

SPECS_GIN = {
    "4003": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ."],
        "test_cmd": ['go test . -v -run "TestMethodNotAllowedNoRoute"'],
    },
    "3820": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./binding"],
        "test_cmd": ['go test -v ./binding -run "^TestMapping"'],
    },
    "3741": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ."],
        "test_cmd": ['go test -v . -run "^TestColor"'],
    },
    "2755": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ."],
        "test_cmd": ['go test -v . -run "^TestTree"'],
    },
    "3227": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ."],
        "test_cmd": ['go test -v . -run "^TestRedirect"'],
    },
    "2121": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ./..."],
        "test_cmd": ['go test -v ./... -run "^Test.*Reader"'],
    },
    "1957": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ."],
        "test_cmd": ['go test -v . -run "^TestContext.*Bind"'],
    },
    "1805": {
        "docker_specs": {"go_version": "1.23.8"},
        "install": ["go test -c ."],
        "test_cmd": ['go test -v . -run "^Test.*Router"'],
    },
}


MAP_REPO_VERSION_TO_SPECS_GO = {
    "caddyserver/caddy": SPECS_CADDY,
    "hashicorp/terraform": SPECS_TERRAFORM,
    "prometheus/prometheus": SPECS_PROMETHEUS,
    "gohugoio/hugo": SPECS_HUGO,
    "gin-gonic/gin": SPECS_GIN,
}

# Constants - Repository Specific Installation Instructions
MAP_REPO_TO_INSTALL_GO = {}
