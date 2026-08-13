
FROM --platform=linux/amd64 maven:3.9.12-eclipse-temurin-17-noble

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

RUN <<EOF_c0eea44384ca
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/projectlombok/lombok /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 984cd1d5cf0af7263efaf167dc308ab59406cd68
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 984cd1d5cf0af7263efaf167dc308ab59406cd68)
TARGET_EPOCH=$(git show -s --format=%ct 984cd1d5cf0af7263efaf167dc308ab59406cd68)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
{ head -n -1 buildScripts/tests.ant.xml; echo '<target name="test.instance" depends="test.compile, test.formatter.compile" description="Runs test cases for the swe-bench instance">
      <junit printsummary="yes" fork="true" forkmode="once" haltonfailure="no">
        <formatter classname="lombok.ant.SimpleTestFormatter" usefile="false" unless="tests.quiet" />
        <classpath location="build/ant" />
        <classpath refid="cp.test" />
        <classpath refid="cp.stripe" />
        <classpath refid="packing.basedirs.path" />
        <classpath location="build/tests" />
        <classpath location="build/teststubs" />
        <test name="lombok.transform.TestWithDelombok" />
      </junit>
    </target>'; tail -n 1 buildScripts/tests.ant.xml; } > temp_file && mv temp_file buildScripts/tests.ant.xml
ant test.compile
EOF_c0eea44384ca


WORKDIR /testbed
