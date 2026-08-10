"""
Shared constants for the multilingual dockerfile generator.
"""

CONTAINER_WORKDIR = "/testbed"
CONTAINER_ENV_NAME = "testbed"

REPO_BASE_COMMIT_BRANCH: dict[str, dict[str, str]] = {}

START_TEST_OUTPUT = ">>>>> Start Test Output"
END_TEST_OUTPUT = ">>>>> End Test Output"

FAIL_ONLY_REPOS: set[str] = set()  # No fail-only repos in multilingual

MAP_REPO_TO_PARSER_NAME = {
    # C
    "redis/redis": "parse_log_redis",
    "jqlang/jq": "parse_log_jq",
    "nlohmann/json": "parse_log_doctest",
    "micropython/micropython": "parse_log_micropython_test",
    "valkey-io/valkey": "parse_log_redis",
    "fmtlib/fmt": "parse_log_googletest",
    # Go
    "caddyserver/caddy": "parse_log_gotest",
    "hashicorp/terraform": "parse_log_gotest",
    "prometheus/prometheus": "parse_log_gotest",
    "gohugoio/hugo": "parse_log_gotest",
    "gin-gonic/gin": "parse_log_gotest",
    # Java
    "google/gson": "parse_log_maven",
    "apache/druid": "parse_log_maven",
    "javaparser/javaparser": "parse_log_maven",
    "projectlombok/lombok": "parse_log_ant",
    "apache/lucene": "parse_log_gradle_custom",
    "reactivex/rxjava": "parse_log_gradle_custom",
    # JavaScript (multilingual subset)
    "Automattic/wp-calypso": "parse_log_calypso",
    "chartjs/Chart.js": "parse_log_chart_js",
    "markedjs/marked": "parse_log_marked",
    "processing/p5.js": "parse_log_p5js",
    "diegomura/react-pdf": "parse_log_react_pdf",
    "babel/babel": "parse_log_jest",
    "vuejs/core": "parse_log_vitest",
    "facebook/docusaurus": "parse_log_jest",
    "immutable-js/immutable-js": "parse_log_immutable_js",
    "mrdoob/three.js": "parse_log_tap",
    "preactjs/preact": "parse_log_karma",
    "axios/axios": "parse_log_tap",
    # PHP
    "phpoffice/phpspreadsheet": "parse_log_phpunit",
    "laravel/framework": "parse_log_phpunit",
    "php-cs-fixer/php-cs-fixer": "parse_log_phpunit",
    "briannesbitt/carbon": "parse_log_phpunit",
    # Ruby
    "jekyll/jekyll": "parse_log_jekyll",
    "fluent/fluentd": "parse_log_ruby_unit",
    "fastlane/fastlane": "parse_log_rspec_transformed_json",
    "jordansissel/fpm": "parse_log_rspec_transformed_json",
    "faker-ruby/faker": "parse_log_ruby_unit",
    "rubocop/rubocop": "parse_log_rspec_transformed_json",
    # Rust
    "burntsushi/ripgrep": "parse_log_cargo",
    "sharkdp/bat": "parse_log_cargo",
    "astral-sh/ruff": "parse_log_cargo",
    "tokio-rs/tokio": "parse_log_cargo",
    "uutils/coreutils": "parse_log_cargo",
    "nushell/nushell": "parse_log_cargo",
    "tokio-rs/axum": "parse_log_cargo",
}

# Per-instance repairs, keyed by instance_id. Files in src/dockerfiles/ are
# generated and get overwritten, so fixes belong here.
#
# isolate_streams: emit the test-output markers on stdout (instead of relying on
#   the `set -x` trace, which goes to stderr) and divert the test command's stderr
#   for the duration of the run. Without it, stdout and stderr interleave with no
#   line synchronisation and results can land outside the parsed region or get
#   spliced mid-line. Only needed where that has actually been observed.
INSTANCE_OVERRIDES: dict[str, dict] = {
    "apache__lucene-13170": {
        "isolate_streams": True,
        "why": "gradle warnings on stderr splice mid-line, e.g. `testSliceEnd PASSEDWARNING: ...`",
    },
    "fastlane__fastlane-21857": {
        "isolate_streams": True,
        "why": "rspec|tail|jq stdout is block-buffered and can flush after the End marker",
    },
}
