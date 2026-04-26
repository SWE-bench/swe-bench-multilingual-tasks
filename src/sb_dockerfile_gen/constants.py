"""
Shared constants for the multilingual dockerfile generator.
"""

CONTAINER_WORKDIR = "/testbed"
CONTAINER_ENV_NAME = "testbed"

REPO_BASE_COMMIT_BRANCH: dict[str, dict[str, str]] = {}

START_TEST_OUTPUT = ">>>>> Start Test Output"
END_TEST_OUTPUT = ">>>>> End Test Output"

FAIL_ONLY_REPOS: set[str] = set()  # No fail-only repos in multilingual

# p5.js v0.6/v0.7 strip the structured JSON reporter (see the multimodal
# generator's specs/p5_js.py `_REPORTER_INCOMPATIBLE_VERSIONS`); newer
# versions install it.
_P5JS_REPORTER_INCOMPATIBLE_VERSIONS = {"0.6", "0.7"}


def _pick_p5js_parser(instance: dict) -> str:
    if instance.get("version") in _P5JS_REPORTER_INCOMPATIBLE_VERSIONS:
        return "parse_log_p5js_mocha_spec"
    return "parse_log_p5js_json"


# immutable-js: PR 2005 uses jest --json (transformed), 2006 uses jest --verbose.
_IMMUTABLE_JS_JEST_JSON_PRS = {"2005"}
_IMMUTABLE_JS_JEST_PRS = {"2006"}


def _pick_immutable_js_parser(instance: dict) -> str:
    pr = instance["instance_id"].split("-")[-1]
    if pr in _IMMUTABLE_JS_JEST_JSON_PRS:
        return "parse_log_jest_json"
    if pr in _IMMUTABLE_JS_JEST_PRS:
        return "parse_log_jest"
    raise ValueError(f"Unknown immutable-js instance: {instance['instance_id']}")


# Values are either a parser-name string (constant for the repo) or a callable
# `(instance) -> name` for repos whose parser depends on the instance.
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
    "processing/p5.js": _pick_p5js_parser,
    "diegomura/react-pdf": "parse_log_react_pdf",
    "babel/babel": "parse_log_jest",
    "vuejs/core": "parse_log_vitest",
    "facebook/docusaurus": "parse_log_jest",
    "immutable-js/immutable-js": _pick_immutable_js_parser,
    "mrdoob/three.js": "parse_log_tap",
    "preactjs/preact": "parse_log_karma_text",
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
