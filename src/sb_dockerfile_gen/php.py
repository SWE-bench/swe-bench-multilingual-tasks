_DOCKERFILE_BASE_PHP = r"""
FROM --platform=linux/amd64 php:{php_version}

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
"""

# Constants - Task Instance Installation Environment
SPECS_PHPSPREADSHEET = {
    "4313": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-4313.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Reader/Ods/FormulaTranslatorTest.php"
        ],
    },
    "4214": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-4214.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Calculation/Functions/MathTrig/RoundDownTest.php"
        ],
    },
    "4186": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-4186.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Writer/Xlsx/FunctionPrefixTest.php"
        ],
    },
    "4114": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-4114.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Worksheet/Issue4112Test.php"
        ],
    },
    "3940": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-3940.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Worksheet/WorksheetTest.php"
        ],
    },
    "3903": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-3903.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Shared/StringHelperTest.php"
        ],
    },
    "3570": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-3570.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Calculation/Functions/LookupRef/VLookupTest.php"
        ],
    },
    "3463": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-3463.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Writer/Xlsx/FunctionPrefixTest.php"
        ],
    },
    "3469": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-3469.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Style/StyleTest.php"
        ],
    },
    "3659": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/phpoffice__phpspreadsheet-3659.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "./vendor/bin/phpunit --testdox --colors=never tests/PhpSpreadsheetTests/Worksheet/Table/Issue3635Test.php"
        ],
    },
}

SPECS_LARAVEL_FRAMEWORK = {
    "53914": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-53914.composer.json",
        "composer_lock": "php/laravel__framework-53914.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Integration/Database/DatabaseConnectionsTest.php"
        ],
    },
    "53206": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-53206.composer.json",
        "composer_lock": "php/laravel__framework-53206.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Support/SupportJsTest.php"
        ],
    },
    "52866": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-52866.composer.json",
        "composer_lock": "php/laravel__framework-52866.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Container/ContextualAttributeBindingTest.php"
        ],
    },
    "52684": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-52684.composer.json",
        "composer_lock": "php/laravel__framework-52684.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Support/SupportStrTest.php"
        ],
    },
    "52680": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-52680.composer.json",
        "composer_lock": "php/laravel__framework-52680.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Database/DatabaseEloquentInverseRelationTest.php"
        ],
    },
    "52451": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-52451.composer.json",
        "composer_lock": "php/laravel__framework-52451.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Validation/ValidationValidatorTest.php --filter 'custom'"
        ],
    },
    "53949": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-53949.composer.json",
        "composer_lock": "php/laravel__framework-53949.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Support/OnceTest.php"
        ],
    },
    "51890": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-51890.composer.json",
        "composer_lock": "php/laravel__framework-51890.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Validation/ValidationValidatorTest.php --filter 'attribute'"
        ],
    },
    "51195": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-51195.composer.json",
        "composer_lock": "php/laravel__framework-51195.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/View/Blade/BladeVerbatimTest.php"
        ],
    },
    "48636": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-48636.composer.json",
        "composer_lock": "php/laravel__framework-48636.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Database/DatabaseEloquentModelTest.php"
        ],
    },
    "48573": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-48573.composer.json",
        "composer_lock": "php/laravel__framework-48573.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Cache/CacheArrayStoreTest.php"
        ],
    },
    "46234": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-46234.composer.json",
        "composer_lock": "php/laravel__framework-46234.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Routing/RoutingUrlGeneratorTest.php"
        ],
    },
    "53696": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_json": "php/laravel__framework-53696.composer.json",
        "composer_lock": "php/laravel__framework-53696.composer.lock",
        "install": [
            "export COMPOSER_ROOT_VERSION=12.50.0",
            "composer install",
        ],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Database/DatabaseSchemaBlueprintTest.php"
        ],
    },
}

SPECS_PHP_CS_FIXER = {
    "8367": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-8367.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/Import/FullyQualifiedStrictTypesFixerTest.php"
        ],
    },
    "8331": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-8331.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/LanguageConstruct/NullableTypeDeclarationFixerTest.php"
        ],
    },
    "8075": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-8075.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/PhpUnit/PhpUnitAttributesFixerTest.php"
        ],
    },
    "8064": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-8064.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/StringNotation/SimpleToComplexStringVariableFixerTest.php"
        ],
    },
    "7998": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-7998.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/Casing/ConstantCaseFixerTest.php",
        ],
    },
    "7875": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-7875.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/Whitespace/StatementIndentationFixerTest.php",
        ],
    },
    "7635": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-7635.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/Import/FullyQualifiedStrictTypesFixerTest.php",
        ],
    },
    "7523": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-7523.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/Operator/BinaryOperatorSpacesFixerTest.php",
        ],
    },
    "8256": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-8256.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/PhpTag/BlankLineAfterOpeningTagFixerTest.php",
        ],
    },
    "7663": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/php-cs-fixer__php-cs-fixer-7663.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Fixer/Whitespace/StatementIndentationFixerTest.php",
        ],
    },
}

SPECS_CARBON = {
    "3103": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-3103.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonImmutable/SettersTest.php"
        ],
    },
    "3098": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-3098.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonInterval/ConstructTest.php"
        ],
    },
    "3073": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-3073.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonInterval/TotalTest.php"
        ],
    },
    "3041": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-3041.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonPeriod/CreateTest.php"
        ],
    },
    "3005": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-3005.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonInterval/ConstructTest.php"
        ],
    },
    "2981": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-2981.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonInterval/TotalTest.php"
        ],
    },
    "2813": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-2813.composer.lock",
        "install": ["composer install"],
        # Patch involves adding a new dependency, so we need to re-install
        "build": ["composer update", "composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Factory/FactoryTest.php"
        ],
    },
    "2752": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-2752.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonImmutable/IsTest.php"
        ],
    },
    "2665": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-2665.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/Carbon/RoundTest.php"
        ],
    },
    "2762": {
        "docker_specs": {"php_version": "8.3.16"},
        "composer_lock": "php/briannesbitt__carbon-2762.composer.lock",
        "install": ["composer install"],
        "test_cmd": [
            "vendor/bin/phpunit --testdox --colors=never tests/CarbonInterval/RoundingTest.php"
        ],
    },
}

MAP_REPO_VERSION_TO_SPECS_PHP = {
    "phpoffice/phpspreadsheet": SPECS_PHPSPREADSHEET,
    "laravel/framework": SPECS_LARAVEL_FRAMEWORK,
    "php-cs-fixer/php-cs-fixer": SPECS_PHP_CS_FIXER,
    "briannesbitt/carbon": SPECS_CARBON,
}

# Constants - Repository Specific Installation Instructions
MAP_REPO_TO_INSTALL_PHP = {}
