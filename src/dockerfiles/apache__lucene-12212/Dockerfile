
FROM --platform=linux/amd64 maven:3.9-eclipse-temurin-17

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

RUN <<EOF_7655739e6622
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/apache/lucene /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard b84b360f588c60e2ebdcaa2ce2e6d49f99dd9deb
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci b84b360f588c60e2ebdcaa2ce2e6d49f99dd9deb)
git tag -l | while read tag; do TAG_COMMIT=$(git rev-list -n 1 "$tag"); TAG_TIME=$(git show -s --format=%ci "$TAG_COMMIT"); if [[ "$TAG_TIME" > "$TARGET_TIMESTAMP" ]]; then git tag -d "$tag"; fi; done
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
sed -i '
/testLogging {/,/}/{
  /testLogging {/r /dev/stdin
  d
}
' gradle/testing/defaults-tests.gradle << 'EOF'
testLogging {
  showStandardStreams = true
  // set options for log level LIFECYCLE
  events TestLogEvent.FAILED,
         TestLogEvent.PASSED,
         TestLogEvent.SKIPPED,
         TestLogEvent.STANDARD_OUT
  exceptionFormat TestExceptionFormat.FULL
  showExceptions true
  showCauses true
  showStackTraces true

  // set options for log level DEBUG and INFO
  debug {
      events TestLogEvent.STARTED,
             TestLogEvent.FAILED,
             TestLogEvent.PASSED,
             TestLogEvent.SKIPPED,
             TestLogEvent.STANDARD_ERROR,
             TestLogEvent.STANDARD_OUT
      exceptionFormat TestExceptionFormat.FULL
  }
  info.events = debug.events
  info.exceptionFormat = debug.exceptionFormat

  afterSuite { desc, result ->
      if (!desc.parent) { // will match the outermost suite
          def output = "Results: ${result.resultType} (${result.testCount} tests, ${result.successfulTestCount} passed, ${result.failedTestCount} failed, ${result.skippedTestCount} skipped)"
          def startItem = '|  ', endItem = '  |'
          def repeatLength = startItem.length() + output.length() + endItem.length()
          println('\n' + ('-' * repeatLength) + '\n' + startItem + output + endItem + '\n' + ('-' * repeatLength))
      }
  }
}
EOF
EOF_7655739e6622


WORKDIR /testbed
