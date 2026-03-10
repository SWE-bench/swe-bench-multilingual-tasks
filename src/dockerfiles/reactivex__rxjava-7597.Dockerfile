
FROM --platform=linux/amd64 maven:3.9-eclipse-temurin-11

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

RUN <<EOF_37939b68ba88
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/reactivex/rxjava /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard 13a8d83656940dce0c18e8e0a2a17ac157dd1ddb
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci 13a8d83656940dce0c18e8e0a2a17ac157dd1ddb)
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
' build.gradle << 'EOF'
testLogging {
    outputs.upToDateWhen { false }
    showStandardStreams = true
    showStackTraces = true

    // Show output for all logging levels
    events = ['passed', 'skipped', 'failed', 'standardOut', 'standardError']

    // set options for log level LIFECYCLE
    events org.gradle.api.tasks.testing.logging.TestLogEvent.FAILED,
           org.gradle.api.tasks.testing.logging.TestLogEvent.PASSED,
           org.gradle.api.tasks.testing.logging.TestLogEvent.SKIPPED,
           org.gradle.api.tasks.testing.logging.TestLogEvent.STANDARD_OUT,
           org.gradle.api.tasks.testing.logging.TestLogEvent.STANDARD_ERROR
    exceptionFormat org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
    showExceptions true
    showCauses true
    showStackTraces true

    // set options for log level DEBUG and INFO
    debug {
        events org.gradle.api.tasks.testing.logging.TestLogEvent.STARTED,
               org.gradle.api.tasks.testing.logging.TestLogEvent.FAILED,
               org.gradle.api.tasks.testing.logging.TestLogEvent.PASSED,
               org.gradle.api.tasks.testing.logging.TestLogEvent.SKIPPED,
               org.gradle.api.tasks.testing.logging.TestLogEvent.STANDARD_ERROR,
               org.gradle.api.tasks.testing.logging.TestLogEvent.STANDARD_OUT
        exceptionFormat org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
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
EOF_37939b68ba88


WORKDIR /testbed
