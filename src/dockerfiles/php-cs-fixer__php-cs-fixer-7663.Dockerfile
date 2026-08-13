
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

RUN <<EOF_6947eff5282d
#!/bin/bash
set -euxo pipefail
git clone -o origin  --single-branch https://github.com/php-cs-fixer/php-cs-fixer /testbed
chmod -R 777 /testbed
cd /testbed
git reset --hard c5cde0cf7542234dc061af8a25f77fcdad430e35
git remote remove origin
TARGET_TIMESTAMP=$(git show -s --format=%ci c5cde0cf7542234dc061af8a25f77fcdad430e35)
TARGET_EPOCH=$(git show -s --format=%ct c5cde0cf7542234dc061af8a25f77fcdad430e35)
for tag in $(git tag -l); do TAG_EPOCH=$(git log -1 --format=%ct "$tag" 2>/dev/null || echo 0); if [ "${TAG_EPOCH:-0}" -gt "$TARGET_EPOCH" ]; then git tag -d "$tag" >/dev/null 2>&1 || true; fi; done
git branch | grep -v '^\*' | xargs -r git branch -D || true
git reflog expire --expire=now --all
git gc --prune=now --aggressive
AFTER_TIMESTAMP=$(date -d "$TARGET_TIMESTAMP + 1 second" '+%Y-%m-%d %H:%M:%S')
COMMIT_COUNT=$(git log --oneline --all --since="$AFTER_TIMESTAMP" | wc -l)
[ "$COMMIT_COUNT" -eq 0 ] || exit 1
cd - || true
cd /testbed
cat <<'EOF_e8434e76373c' > composer.lock
{
    "_readme": [
        "This file locks the dependencies of your project to a known state",
        "Read more about it at https://getcomposer.org/doc/01-basic-usage.md#installing-dependencies",
        "This file is @generated automatically"
    ],
    "content-hash": "16c60a3f70b7442c654eb6555b0bb3f9",
    "packages": [
        {
            "name": "composer/pcre",
            "version": "3.3.2",
            "source": {
                "type": "git",
                "url": "https://github.com/composer/pcre.git",
                "reference": "b2bed4734f0cc156ee1fe9c0da2550420d99a21e"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/composer/pcre/zipball/b2bed4734f0cc156ee1fe9c0da2550420d99a21e",
                "reference": "b2bed4734f0cc156ee1fe9c0da2550420d99a21e",
                "shasum": ""
            },
            "require": {
                "php": "^7.4 || ^8.0"
            },
            "conflict": {
                "phpstan/phpstan": "<1.11.10"
            },
            "require-dev": {
                "phpstan/phpstan": "^1.12 || ^2",
                "phpstan/phpstan-strict-rules": "^1 || ^2",
                "phpunit/phpunit": "^8 || ^9"
            },
            "type": "library",
            "extra": {
                "phpstan": {
                    "includes": [
                        "extension.neon"
                    ]
                },
                "branch-alias": {
                    "dev-main": "3.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Composer\\Pcre\\": "src"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Jordi Boggiano",
                    "email": "j.boggiano@seld.be",
                    "homepage": "http://seld.be"
                }
            ],
            "description": "PCRE wrapping library that offers type-safe preg_* replacements.",
            "keywords": [
                "PCRE",
                "preg",
                "regex",
                "regular expression"
            ],
            "support": {
                "issues": "https://github.com/composer/pcre/issues",
                "source": "https://github.com/composer/pcre/tree/3.3.2"
            },
            "funding": [
                {
                    "url": "https://packagist.com",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/composer",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/composer/composer",
                    "type": "tidelift"
                }
            ],
            "time": "2024-11-12T16:29:46+00:00"
        },
        {
            "name": "composer/semver",
            "version": "3.4.4",
            "source": {
                "type": "git",
                "url": "https://github.com/composer/semver.git",
                "reference": "198166618906cb2de69b95d7d47e5fa8aa1b2b95"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/composer/semver/zipball/198166618906cb2de69b95d7d47e5fa8aa1b2b95",
                "reference": "198166618906cb2de69b95d7d47e5fa8aa1b2b95",
                "shasum": ""
            },
            "require": {
                "php": "^5.3.2 || ^7.0 || ^8.0"
            },
            "require-dev": {
                "phpstan/phpstan": "^1.11",
                "symfony/phpunit-bridge": "^3 || ^7"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "3.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Composer\\Semver\\": "src"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nils Adermann",
                    "email": "naderman@naderman.de",
                    "homepage": "http://www.naderman.de"
                },
                {
                    "name": "Jordi Boggiano",
                    "email": "j.boggiano@seld.be",
                    "homepage": "http://seld.be"
                },
                {
                    "name": "Rob Bast",
                    "email": "rob.bast@gmail.com",
                    "homepage": "http://robbast.nl"
                }
            ],
            "description": "Semver library that offers utilities, version constraint parsing and validation.",
            "keywords": [
                "semantic",
                "semver",
                "validation",
                "versioning"
            ],
            "support": {
                "irc": "ircs://irc.libera.chat:6697/composer",
                "issues": "https://github.com/composer/semver/issues",
                "source": "https://github.com/composer/semver/tree/3.4.4"
            },
            "funding": [
                {
                    "url": "https://packagist.com",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/composer",
                    "type": "github"
                }
            ],
            "time": "2025-08-20T19:15:30+00:00"
        },
        {
            "name": "composer/xdebug-handler",
            "version": "3.0.5",
            "source": {
                "type": "git",
                "url": "https://github.com/composer/xdebug-handler.git",
                "reference": "6c1925561632e83d60a44492e0b344cf48ab85ef"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/composer/xdebug-handler/zipball/6c1925561632e83d60a44492e0b344cf48ab85ef",
                "reference": "6c1925561632e83d60a44492e0b344cf48ab85ef",
                "shasum": ""
            },
            "require": {
                "composer/pcre": "^1 || ^2 || ^3",
                "php": "^7.2.5 || ^8.0",
                "psr/log": "^1 || ^2 || ^3"
            },
            "require-dev": {
                "phpstan/phpstan": "^1.0",
                "phpstan/phpstan-strict-rules": "^1.1",
                "phpunit/phpunit": "^8.5 || ^9.6 || ^10.5"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Composer\\XdebugHandler\\": "src"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "John Stevenson",
                    "email": "john-stevenson@blueyonder.co.uk"
                }
            ],
            "description": "Restarts a process without Xdebug.",
            "keywords": [
                "Xdebug",
                "performance"
            ],
            "support": {
                "irc": "ircs://irc.libera.chat:6697/composer",
                "issues": "https://github.com/composer/xdebug-handler/issues",
                "source": "https://github.com/composer/xdebug-handler/tree/3.0.5"
            },
            "funding": [
                {
                    "url": "https://packagist.com",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/composer",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/composer/composer",
                    "type": "tidelift"
                }
            ],
            "time": "2024-05-06T16:37:16+00:00"
        },
        {
            "name": "psr/container",
            "version": "2.0.2",
            "source": {
                "type": "git",
                "url": "https://github.com/php-fig/container.git",
                "reference": "c71ecc56dfe541dbd90c5360474fbc405f8d5963"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-fig/container/zipball/c71ecc56dfe541dbd90c5360474fbc405f8d5963",
                "reference": "c71ecc56dfe541dbd90c5360474fbc405f8d5963",
                "shasum": ""
            },
            "require": {
                "php": ">=7.4.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "2.0.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Psr\\Container\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "PHP-FIG",
                    "homepage": "https://www.php-fig.org/"
                }
            ],
            "description": "Common Container Interface (PHP FIG PSR-11)",
            "homepage": "https://github.com/php-fig/container",
            "keywords": [
                "PSR-11",
                "container",
                "container-interface",
                "container-interop",
                "psr"
            ],
            "support": {
                "issues": "https://github.com/php-fig/container/issues",
                "source": "https://github.com/php-fig/container/tree/2.0.2"
            },
            "time": "2021-11-05T16:47:00+00:00"
        },
        {
            "name": "psr/event-dispatcher",
            "version": "1.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/php-fig/event-dispatcher.git",
                "reference": "dbefd12671e8a14ec7f180cab83036ed26714bb0"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-fig/event-dispatcher/zipball/dbefd12671e8a14ec7f180cab83036ed26714bb0",
                "reference": "dbefd12671e8a14ec7f180cab83036ed26714bb0",
                "shasum": ""
            },
            "require": {
                "php": ">=7.2.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "1.0.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Psr\\EventDispatcher\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "PHP-FIG",
                    "homepage": "http://www.php-fig.org/"
                }
            ],
            "description": "Standard interfaces for event handling.",
            "keywords": [
                "events",
                "psr",
                "psr-14"
            ],
            "support": {
                "issues": "https://github.com/php-fig/event-dispatcher/issues",
                "source": "https://github.com/php-fig/event-dispatcher/tree/1.0.0"
            },
            "time": "2019-01-08T18:20:26+00:00"
        },
        {
            "name": "psr/log",
            "version": "3.0.2",
            "source": {
                "type": "git",
                "url": "https://github.com/php-fig/log.git",
                "reference": "f16e1d5863e37f8d8c2a01719f5b34baa2b714d3"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-fig/log/zipball/f16e1d5863e37f8d8c2a01719f5b34baa2b714d3",
                "reference": "f16e1d5863e37f8d8c2a01719f5b34baa2b714d3",
                "shasum": ""
            },
            "require": {
                "php": ">=8.0.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "3.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Psr\\Log\\": "src"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "PHP-FIG",
                    "homepage": "https://www.php-fig.org/"
                }
            ],
            "description": "Common interface for logging libraries",
            "homepage": "https://github.com/php-fig/log",
            "keywords": [
                "log",
                "psr",
                "psr-3"
            ],
            "support": {
                "source": "https://github.com/php-fig/log/tree/3.0.2"
            },
            "time": "2024-09-11T13:17:53+00:00"
        },
        {
            "name": "sebastian/diff",
            "version": "5.1.1",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/diff.git",
                "reference": "c41e007b4b62af48218231d6c2275e4c9b975b2e"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/diff/zipball/c41e007b4b62af48218231d6c2275e4c9b975b2e",
                "reference": "c41e007b4b62af48218231d6c2275e4c9b975b2e",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0",
                "symfony/process": "^6.4"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "5.1-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                },
                {
                    "name": "Kore Nordmann",
                    "email": "mail@kore-nordmann.de"
                }
            ],
            "description": "Diff implementation",
            "homepage": "https://github.com/sebastianbergmann/diff",
            "keywords": [
                "diff",
                "udiff",
                "unidiff",
                "unified diff"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/diff/issues",
                "security": "https://github.com/sebastianbergmann/diff/security/policy",
                "source": "https://github.com/sebastianbergmann/diff/tree/5.1.1"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2024-03-02T07:15:17+00:00"
        },
        {
            "name": "symfony/console",
            "version": "v7.4.7",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/console.git",
                "reference": "e1e6770440fb9c9b0cf725f81d1361ad1835329d"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/console/zipball/e1e6770440fb9c9b0cf725f81d1361ad1835329d",
                "reference": "e1e6770440fb9c9b0cf725f81d1361ad1835329d",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/deprecation-contracts": "^2.5|^3",
                "symfony/polyfill-mbstring": "~1.0",
                "symfony/service-contracts": "^2.5|^3",
                "symfony/string": "^7.2|^8.0"
            },
            "conflict": {
                "symfony/dependency-injection": "<6.4",
                "symfony/dotenv": "<6.4",
                "symfony/event-dispatcher": "<6.4",
                "symfony/lock": "<6.4",
                "symfony/process": "<6.4"
            },
            "provide": {
                "psr/log-implementation": "1.0|2.0|3.0"
            },
            "require-dev": {
                "psr/log": "^1|^2|^3",
                "symfony/config": "^6.4|^7.0|^8.0",
                "symfony/dependency-injection": "^6.4|^7.0|^8.0",
                "symfony/event-dispatcher": "^6.4|^7.0|^8.0",
                "symfony/http-foundation": "^6.4|^7.0|^8.0",
                "symfony/http-kernel": "^6.4|^7.0|^8.0",
                "symfony/lock": "^6.4|^7.0|^8.0",
                "symfony/messenger": "^6.4|^7.0|^8.0",
                "symfony/process": "^6.4|^7.0|^8.0",
                "symfony/stopwatch": "^6.4|^7.0|^8.0",
                "symfony/var-dumper": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Console\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Eases the creation of beautiful and testable command line interfaces",
            "homepage": "https://symfony.com",
            "keywords": [
                "cli",
                "command-line",
                "console",
                "terminal"
            ],
            "support": {
                "source": "https://github.com/symfony/console/tree/v7.4.7"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-03-06T14:06:20+00:00"
        },
        {
            "name": "symfony/deprecation-contracts",
            "version": "v3.6.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/deprecation-contracts.git",
                "reference": "63afe740e99a13ba87ec199bb07bbdee937a5b62"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/deprecation-contracts/zipball/63afe740e99a13ba87ec199bb07bbdee937a5b62",
                "reference": "63afe740e99a13ba87ec199bb07bbdee937a5b62",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/contracts",
                    "name": "symfony/contracts"
                },
                "branch-alias": {
                    "dev-main": "3.6-dev"
                }
            },
            "autoload": {
                "files": [
                    "function.php"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "A generic function and convention to trigger deprecation notices",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/deprecation-contracts/tree/v3.6.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2024-09-25T14:21:43+00:00"
        },
        {
            "name": "symfony/event-dispatcher",
            "version": "v7.4.4",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/event-dispatcher.git",
                "reference": "dc2c0eba1af673e736bb851d747d266108aea746"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/event-dispatcher/zipball/dc2c0eba1af673e736bb851d747d266108aea746",
                "reference": "dc2c0eba1af673e736bb851d747d266108aea746",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/event-dispatcher-contracts": "^2.5|^3"
            },
            "conflict": {
                "symfony/dependency-injection": "<6.4",
                "symfony/service-contracts": "<2.5"
            },
            "provide": {
                "psr/event-dispatcher-implementation": "1.0",
                "symfony/event-dispatcher-implementation": "2.0|3.0"
            },
            "require-dev": {
                "psr/log": "^1|^2|^3",
                "symfony/config": "^6.4|^7.0|^8.0",
                "symfony/dependency-injection": "^6.4|^7.0|^8.0",
                "symfony/error-handler": "^6.4|^7.0|^8.0",
                "symfony/expression-language": "^6.4|^7.0|^8.0",
                "symfony/framework-bundle": "^6.4|^7.0|^8.0",
                "symfony/http-foundation": "^6.4|^7.0|^8.0",
                "symfony/service-contracts": "^2.5|^3",
                "symfony/stopwatch": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\EventDispatcher\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Provides tools that allow your application components to communicate with each other by dispatching events and listening to them",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/event-dispatcher/tree/v7.4.4"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-01-05T11:45:34+00:00"
        },
        {
            "name": "symfony/event-dispatcher-contracts",
            "version": "v3.6.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/event-dispatcher-contracts.git",
                "reference": "59eb412e93815df44f05f342958efa9f46b1e586"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/event-dispatcher-contracts/zipball/59eb412e93815df44f05f342958efa9f46b1e586",
                "reference": "59eb412e93815df44f05f342958efa9f46b1e586",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1",
                "psr/event-dispatcher": "^1"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/contracts",
                    "name": "symfony/contracts"
                },
                "branch-alias": {
                    "dev-main": "3.6-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Symfony\\Contracts\\EventDispatcher\\": ""
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Generic abstractions related to dispatching event",
            "homepage": "https://symfony.com",
            "keywords": [
                "abstractions",
                "contracts",
                "decoupling",
                "interfaces",
                "interoperability",
                "standards"
            ],
            "support": {
                "source": "https://github.com/symfony/event-dispatcher-contracts/tree/v3.6.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2024-09-25T14:21:43+00:00"
        },
        {
            "name": "symfony/filesystem",
            "version": "v7.4.6",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/filesystem.git",
                "reference": "3ebc794fa5315e59fd122561623c2e2e4280538e"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/filesystem/zipball/3ebc794fa5315e59fd122561623c2e2e4280538e",
                "reference": "3ebc794fa5315e59fd122561623c2e2e4280538e",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/polyfill-ctype": "~1.8",
                "symfony/polyfill-mbstring": "~1.8"
            },
            "require-dev": {
                "symfony/process": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Filesystem\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Provides basic utilities for the filesystem",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/filesystem/tree/v7.4.6"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-02-25T16:50:00+00:00"
        },
        {
            "name": "symfony/finder",
            "version": "v7.4.6",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/finder.git",
                "reference": "8655bf1076b7a3a346cb11413ffdabff50c7ffcf"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/finder/zipball/8655bf1076b7a3a346cb11413ffdabff50c7ffcf",
                "reference": "8655bf1076b7a3a346cb11413ffdabff50c7ffcf",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2"
            },
            "require-dev": {
                "symfony/filesystem": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Finder\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Finds files and directories via an intuitive fluent interface",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/finder/tree/v7.4.6"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-01-29T09:40:50+00:00"
        },
        {
            "name": "symfony/options-resolver",
            "version": "v7.4.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/options-resolver.git",
                "reference": "b38026df55197f9e39a44f3215788edf83187b80"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/options-resolver/zipball/b38026df55197f9e39a44f3215788edf83187b80",
                "reference": "b38026df55197f9e39a44f3215788edf83187b80",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/deprecation-contracts": "^2.5|^3"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\OptionsResolver\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Provides an improved replacement for the array_replace PHP function",
            "homepage": "https://symfony.com",
            "keywords": [
                "config",
                "configuration",
                "options"
            ],
            "support": {
                "source": "https://github.com/symfony/options-resolver/tree/v7.4.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2025-11-12T15:39:26+00:00"
        },
        {
            "name": "symfony/polyfill-ctype",
            "version": "v1.33.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/polyfill-ctype.git",
                "reference": "a3cc8b044a6ea513310cbd48ef7333b384945638"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/polyfill-ctype/zipball/a3cc8b044a6ea513310cbd48ef7333b384945638",
                "reference": "a3cc8b044a6ea513310cbd48ef7333b384945638",
                "shasum": ""
            },
            "require": {
                "php": ">=7.2"
            },
            "provide": {
                "ext-ctype": "*"
            },
            "suggest": {
                "ext-ctype": "For best performance"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/polyfill",
                    "name": "symfony/polyfill"
                }
            },
            "autoload": {
                "files": [
                    "bootstrap.php"
                ],
                "psr-4": {
                    "Symfony\\Polyfill\\Ctype\\": ""
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Gert de Pagter",
                    "email": "BackEndTea@gmail.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Symfony polyfill for ctype functions",
            "homepage": "https://symfony.com",
            "keywords": [
                "compatibility",
                "ctype",
                "polyfill",
                "portable"
            ],
            "support": {
                "source": "https://github.com/symfony/polyfill-ctype/tree/v1.33.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2024-09-09T11:45:10+00:00"
        },
        {
            "name": "symfony/polyfill-intl-grapheme",
            "version": "v1.33.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/polyfill-intl-grapheme.git",
                "reference": "380872130d3a5dd3ace2f4010d95125fde5d5c70"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/polyfill-intl-grapheme/zipball/380872130d3a5dd3ace2f4010d95125fde5d5c70",
                "reference": "380872130d3a5dd3ace2f4010d95125fde5d5c70",
                "shasum": ""
            },
            "require": {
                "php": ">=7.2"
            },
            "suggest": {
                "ext-intl": "For best performance"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/polyfill",
                    "name": "symfony/polyfill"
                }
            },
            "autoload": {
                "files": [
                    "bootstrap.php"
                ],
                "psr-4": {
                    "Symfony\\Polyfill\\Intl\\Grapheme\\": ""
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Symfony polyfill for intl's grapheme_* functions",
            "homepage": "https://symfony.com",
            "keywords": [
                "compatibility",
                "grapheme",
                "intl",
                "polyfill",
                "portable",
                "shim"
            ],
            "support": {
                "source": "https://github.com/symfony/polyfill-intl-grapheme/tree/v1.33.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2025-06-27T09:58:17+00:00"
        },
        {
            "name": "symfony/polyfill-intl-normalizer",
            "version": "v1.33.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/polyfill-intl-normalizer.git",
                "reference": "3833d7255cc303546435cb650316bff708a1c75c"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/polyfill-intl-normalizer/zipball/3833d7255cc303546435cb650316bff708a1c75c",
                "reference": "3833d7255cc303546435cb650316bff708a1c75c",
                "shasum": ""
            },
            "require": {
                "php": ">=7.2"
            },
            "suggest": {
                "ext-intl": "For best performance"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/polyfill",
                    "name": "symfony/polyfill"
                }
            },
            "autoload": {
                "files": [
                    "bootstrap.php"
                ],
                "psr-4": {
                    "Symfony\\Polyfill\\Intl\\Normalizer\\": ""
                },
                "classmap": [
                    "Resources/stubs"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Symfony polyfill for intl's Normalizer class and related functions",
            "homepage": "https://symfony.com",
            "keywords": [
                "compatibility",
                "intl",
                "normalizer",
                "polyfill",
                "portable",
                "shim"
            ],
            "support": {
                "source": "https://github.com/symfony/polyfill-intl-normalizer/tree/v1.33.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2024-09-09T11:45:10+00:00"
        },
        {
            "name": "symfony/polyfill-mbstring",
            "version": "v1.33.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/polyfill-mbstring.git",
                "reference": "6d857f4d76bd4b343eac26d6b539585d2bc56493"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/polyfill-mbstring/zipball/6d857f4d76bd4b343eac26d6b539585d2bc56493",
                "reference": "6d857f4d76bd4b343eac26d6b539585d2bc56493",
                "shasum": ""
            },
            "require": {
                "ext-iconv": "*",
                "php": ">=7.2"
            },
            "provide": {
                "ext-mbstring": "*"
            },
            "suggest": {
                "ext-mbstring": "For best performance"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/polyfill",
                    "name": "symfony/polyfill"
                }
            },
            "autoload": {
                "files": [
                    "bootstrap.php"
                ],
                "psr-4": {
                    "Symfony\\Polyfill\\Mbstring\\": ""
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Symfony polyfill for the Mbstring extension",
            "homepage": "https://symfony.com",
            "keywords": [
                "compatibility",
                "mbstring",
                "polyfill",
                "portable",
                "shim"
            ],
            "support": {
                "source": "https://github.com/symfony/polyfill-mbstring/tree/v1.33.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2024-12-23T08:48:59+00:00"
        },
        {
            "name": "symfony/polyfill-php80",
            "version": "v1.33.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/polyfill-php80.git",
                "reference": "0cc9dd0f17f61d8131e7df6b84bd344899fe2608"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/polyfill-php80/zipball/0cc9dd0f17f61d8131e7df6b84bd344899fe2608",
                "reference": "0cc9dd0f17f61d8131e7df6b84bd344899fe2608",
                "shasum": ""
            },
            "require": {
                "php": ">=7.2"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/polyfill",
                    "name": "symfony/polyfill"
                }
            },
            "autoload": {
                "files": [
                    "bootstrap.php"
                ],
                "psr-4": {
                    "Symfony\\Polyfill\\Php80\\": ""
                },
                "classmap": [
                    "Resources/stubs"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Ion Bazan",
                    "email": "ion.bazan@gmail.com"
                },
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Symfony polyfill backporting some PHP 8.0+ features to lower PHP versions",
            "homepage": "https://symfony.com",
            "keywords": [
                "compatibility",
                "polyfill",
                "portable",
                "shim"
            ],
            "support": {
                "source": "https://github.com/symfony/polyfill-php80/tree/v1.33.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2025-01-02T08:10:11+00:00"
        },
        {
            "name": "symfony/polyfill-php81",
            "version": "v1.33.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/polyfill-php81.git",
                "reference": "4a4cfc2d253c21a5ad0e53071df248ed48c6ce5c"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/polyfill-php81/zipball/4a4cfc2d253c21a5ad0e53071df248ed48c6ce5c",
                "reference": "4a4cfc2d253c21a5ad0e53071df248ed48c6ce5c",
                "shasum": ""
            },
            "require": {
                "php": ">=7.2"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/polyfill",
                    "name": "symfony/polyfill"
                }
            },
            "autoload": {
                "files": [
                    "bootstrap.php"
                ],
                "psr-4": {
                    "Symfony\\Polyfill\\Php81\\": ""
                },
                "classmap": [
                    "Resources/stubs"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Symfony polyfill backporting some PHP 8.1+ features to lower PHP versions",
            "homepage": "https://symfony.com",
            "keywords": [
                "compatibility",
                "polyfill",
                "portable",
                "shim"
            ],
            "support": {
                "source": "https://github.com/symfony/polyfill-php81/tree/v1.33.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2024-09-09T11:45:10+00:00"
        },
        {
            "name": "symfony/process",
            "version": "v7.4.5",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/process.git",
                "reference": "608476f4604102976d687c483ac63a79ba18cc97"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/process/zipball/608476f4604102976d687c483ac63a79ba18cc97",
                "reference": "608476f4604102976d687c483ac63a79ba18cc97",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Process\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Executes commands in sub-processes",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/process/tree/v7.4.5"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-01-26T15:07:59+00:00"
        },
        {
            "name": "symfony/service-contracts",
            "version": "v3.6.1",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/service-contracts.git",
                "reference": "45112560a3ba2d715666a509a0bc9521d10b6c43"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/service-contracts/zipball/45112560a3ba2d715666a509a0bc9521d10b6c43",
                "reference": "45112560a3ba2d715666a509a0bc9521d10b6c43",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1",
                "psr/container": "^1.1|^2.0",
                "symfony/deprecation-contracts": "^2.5|^3"
            },
            "conflict": {
                "ext-psr": "<1.1|>=2"
            },
            "type": "library",
            "extra": {
                "thanks": {
                    "url": "https://github.com/symfony/contracts",
                    "name": "symfony/contracts"
                },
                "branch-alias": {
                    "dev-main": "3.6-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Symfony\\Contracts\\Service\\": ""
                },
                "exclude-from-classmap": [
                    "/Test/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Generic abstractions related to writing services",
            "homepage": "https://symfony.com",
            "keywords": [
                "abstractions",
                "contracts",
                "decoupling",
                "interfaces",
                "interoperability",
                "standards"
            ],
            "support": {
                "source": "https://github.com/symfony/service-contracts/tree/v3.6.1"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2025-07-15T11:30:57+00:00"
        },
        {
            "name": "symfony/stopwatch",
            "version": "v7.4.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/stopwatch.git",
                "reference": "8a24af0a2e8a872fb745047180649b8418303084"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/stopwatch/zipball/8a24af0a2e8a872fb745047180649b8418303084",
                "reference": "8a24af0a2e8a872fb745047180649b8418303084",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/service-contracts": "^2.5|^3"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Stopwatch\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Provides a way to profile code",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/stopwatch/tree/v7.4.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2025-08-04T07:05:15+00:00"
        },
        {
            "name": "symfony/string",
            "version": "v7.4.6",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/string.git",
                "reference": "9f209231affa85aa930a5e46e6eb03381424b30b"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/string/zipball/9f209231affa85aa930a5e46e6eb03381424b30b",
                "reference": "9f209231affa85aa930a5e46e6eb03381424b30b",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/deprecation-contracts": "^2.5|^3.0",
                "symfony/polyfill-ctype": "~1.8",
                "symfony/polyfill-intl-grapheme": "~1.33",
                "symfony/polyfill-intl-normalizer": "~1.0",
                "symfony/polyfill-mbstring": "~1.0"
            },
            "conflict": {
                "symfony/translation-contracts": "<2.5"
            },
            "require-dev": {
                "symfony/emoji": "^7.1|^8.0",
                "symfony/http-client": "^6.4|^7.0|^8.0",
                "symfony/intl": "^6.4|^7.0|^8.0",
                "symfony/translation-contracts": "^2.5|^3.0",
                "symfony/var-exporter": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "files": [
                    "Resources/functions.php"
                ],
                "psr-4": {
                    "Symfony\\Component\\String\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Provides an object-oriented API to strings and deals with bytes, UTF-8 code points and grapheme clusters in a unified way",
            "homepage": "https://symfony.com",
            "keywords": [
                "grapheme",
                "i18n",
                "string",
                "unicode",
                "utf-8",
                "utf8"
            ],
            "support": {
                "source": "https://github.com/symfony/string/tree/v7.4.6"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-02-09T09:33:46+00:00"
        }
    ],
    "packages-dev": [
        {
            "name": "facile-it/paraunit",
            "version": "2.8.0",
            "source": {
                "type": "git",
                "url": "https://github.com/facile-it/paraunit.git",
                "reference": "f10b0dd0658164a30e84b1eb4f003dac605ca489"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/facile-it/paraunit/zipball/f10b0dd0658164a30e84b1eb4f003dac605ca489",
                "reference": "f10b0dd0658164a30e84b1eb4f003dac605ca489",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-json": "*",
                "jean85/pretty-package-versions": "^1.5.1||^2.0.1",
                "php": "^8.1",
                "phpunit/php-code-coverage": "^10.1.11||^11.0||^12.0||^13.0",
                "phpunit/php-file-iterator": "^4.0||^5.0||^6.0||^7.0",
                "phpunit/phpunit": "^10.5.4||^11.0||^12.0||^13.0",
                "psr/event-dispatcher": "^1.0",
                "symfony/console": "^4.4||^5.0||^6.0||^7.0||^8.0",
                "symfony/dependency-injection": "^4.4||^5.0||^6.0||^7.0||^8.0",
                "symfony/event-dispatcher": "^4.4||^5.0||^6.0||^7.0||^8.0",
                "symfony/process": "^4.4||^5.0||^6.0||^7.0||^8.0",
                "symfony/stopwatch": "^4.4||^5.0||^6.0||^7.0||^8.0"
            },
            "conflict": {
                "composer/package-versions-deprecated": "<1.11.99"
            },
            "require-dev": {
                "facile-it/facile-coding-standard": "^1.0",
                "jangregor/phpstan-prophecy": "^2.0.0",
                "phpspec/prophecy": "^1.20",
                "phpspec/prophecy-phpunit": "^2.3.0",
                "phpstan/extension-installer": "^1.0",
                "phpstan/phpstan": "2.1.39",
                "phpstan/phpstan-phpunit": "^2.0",
                "phpunit/php-invoker": "^4.0||^5.0||^6.0||^7.0",
                "psalm/plugin-phpunit": "^0.19",
                "psalm/plugin-symfony": "^5.0",
                "rector/rector": "2.3.6",
                "symfony/expression-language": "^4.4||^5.0||^6.0||^7.0||^8.0",
                "symfony/phpunit-bridge": "^6.4||^7.0||^8.0",
                "vimeo/psalm": "^5.5.0||^6.0"
            },
            "suggest": {
                "dama/doctrine-test-bundle": "Useful for Symfony+Doctrine functional testing, providing DB isolation",
                "ext-pcov": "A coverage driver for faster collection"
            },
            "bin": [
                "src/Bin/paraunit"
            ],
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-0.12.x": "0.12-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Paraunit\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "Apache-2.0"
            ],
            "authors": [
                {
                    "name": "Francesco Panina",
                    "email": "francesco.panina@gmail.com"
                },
                {
                    "name": "Alessandro Lai",
                    "email": "alessandro.lai85@gmail.com"
                }
            ],
            "description": "paraunit",
            "homepage": "https://github.com/facile-it/paraunit",
            "keywords": [
                "parallel test",
                "phpunit",
                "testing"
            ],
            "support": {
                "issues": "https://github.com/facile-it/paraunit/issues",
                "source": "https://github.com/facile-it/paraunit/tree/2.8.0"
            },
            "time": "2026-02-23T16:58:18+00:00"
        },
        {
            "name": "guzzlehttp/guzzle",
            "version": "7.10.0",
            "source": {
                "type": "git",
                "url": "https://github.com/guzzle/guzzle.git",
                "reference": "b51ac707cfa420b7bfd4e4d5e510ba8008e822b4"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/guzzle/guzzle/zipball/b51ac707cfa420b7bfd4e4d5e510ba8008e822b4",
                "reference": "b51ac707cfa420b7bfd4e4d5e510ba8008e822b4",
                "shasum": ""
            },
            "require": {
                "ext-json": "*",
                "guzzlehttp/promises": "^2.3",
                "guzzlehttp/psr7": "^2.8",
                "php": "^7.2.5 || ^8.0",
                "psr/http-client": "^1.0",
                "symfony/deprecation-contracts": "^2.2 || ^3.0"
            },
            "provide": {
                "psr/http-client-implementation": "1.0"
            },
            "require-dev": {
                "bamarni/composer-bin-plugin": "^1.8.2",
                "ext-curl": "*",
                "guzzle/client-integration-tests": "3.0.2",
                "php-http/message-factory": "^1.1",
                "phpunit/phpunit": "^8.5.39 || ^9.6.20",
                "psr/log": "^1.1 || ^2.0 || ^3.0"
            },
            "suggest": {
                "ext-curl": "Required for CURL handler support",
                "ext-intl": "Required for Internationalized Domain Name (IDN) support",
                "psr/log": "Required for using the Log middleware"
            },
            "type": "library",
            "extra": {
                "bamarni-bin": {
                    "bin-links": true,
                    "forward-command": false
                }
            },
            "autoload": {
                "files": [
                    "src/functions_include.php"
                ],
                "psr-4": {
                    "GuzzleHttp\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Graham Campbell",
                    "email": "hello@gjcampbell.co.uk",
                    "homepage": "https://github.com/GrahamCampbell"
                },
                {
                    "name": "Michael Dowling",
                    "email": "mtdowling@gmail.com",
                    "homepage": "https://github.com/mtdowling"
                },
                {
                    "name": "Jeremy Lindblom",
                    "email": "jeremeamia@gmail.com",
                    "homepage": "https://github.com/jeremeamia"
                },
                {
                    "name": "George Mponos",
                    "email": "gmponos@gmail.com",
                    "homepage": "https://github.com/gmponos"
                },
                {
                    "name": "Tobias Nyholm",
                    "email": "tobias.nyholm@gmail.com",
                    "homepage": "https://github.com/Nyholm"
                },
                {
                    "name": "Márk Sági-Kazár",
                    "email": "mark.sagikazar@gmail.com",
                    "homepage": "https://github.com/sagikazarmark"
                },
                {
                    "name": "Tobias Schultze",
                    "email": "webmaster@tubo-world.de",
                    "homepage": "https://github.com/Tobion"
                }
            ],
            "description": "Guzzle is a PHP HTTP client library",
            "keywords": [
                "client",
                "curl",
                "framework",
                "http",
                "http client",
                "psr-18",
                "psr-7",
                "rest",
                "web service"
            ],
            "support": {
                "issues": "https://github.com/guzzle/guzzle/issues",
                "source": "https://github.com/guzzle/guzzle/tree/7.10.0"
            },
            "funding": [
                {
                    "url": "https://github.com/GrahamCampbell",
                    "type": "github"
                },
                {
                    "url": "https://github.com/Nyholm",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/guzzlehttp/guzzle",
                    "type": "tidelift"
                }
            ],
            "time": "2025-08-23T22:36:01+00:00"
        },
        {
            "name": "guzzlehttp/promises",
            "version": "2.3.0",
            "source": {
                "type": "git",
                "url": "https://github.com/guzzle/promises.git",
                "reference": "481557b130ef3790cf82b713667b43030dc9c957"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/guzzle/promises/zipball/481557b130ef3790cf82b713667b43030dc9c957",
                "reference": "481557b130ef3790cf82b713667b43030dc9c957",
                "shasum": ""
            },
            "require": {
                "php": "^7.2.5 || ^8.0"
            },
            "require-dev": {
                "bamarni/composer-bin-plugin": "^1.8.2",
                "phpunit/phpunit": "^8.5.44 || ^9.6.25"
            },
            "type": "library",
            "extra": {
                "bamarni-bin": {
                    "bin-links": true,
                    "forward-command": false
                }
            },
            "autoload": {
                "psr-4": {
                    "GuzzleHttp\\Promise\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Graham Campbell",
                    "email": "hello@gjcampbell.co.uk",
                    "homepage": "https://github.com/GrahamCampbell"
                },
                {
                    "name": "Michael Dowling",
                    "email": "mtdowling@gmail.com",
                    "homepage": "https://github.com/mtdowling"
                },
                {
                    "name": "Tobias Nyholm",
                    "email": "tobias.nyholm@gmail.com",
                    "homepage": "https://github.com/Nyholm"
                },
                {
                    "name": "Tobias Schultze",
                    "email": "webmaster@tubo-world.de",
                    "homepage": "https://github.com/Tobion"
                }
            ],
            "description": "Guzzle promises library",
            "keywords": [
                "promise"
            ],
            "support": {
                "issues": "https://github.com/guzzle/promises/issues",
                "source": "https://github.com/guzzle/promises/tree/2.3.0"
            },
            "funding": [
                {
                    "url": "https://github.com/GrahamCampbell",
                    "type": "github"
                },
                {
                    "url": "https://github.com/Nyholm",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/guzzlehttp/promises",
                    "type": "tidelift"
                }
            ],
            "time": "2025-08-22T14:34:08+00:00"
        },
        {
            "name": "guzzlehttp/psr7",
            "version": "2.8.0",
            "source": {
                "type": "git",
                "url": "https://github.com/guzzle/psr7.git",
                "reference": "21dc724a0583619cd1652f673303492272778051"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/guzzle/psr7/zipball/21dc724a0583619cd1652f673303492272778051",
                "reference": "21dc724a0583619cd1652f673303492272778051",
                "shasum": ""
            },
            "require": {
                "php": "^7.2.5 || ^8.0",
                "psr/http-factory": "^1.0",
                "psr/http-message": "^1.1 || ^2.0",
                "ralouphie/getallheaders": "^3.0"
            },
            "provide": {
                "psr/http-factory-implementation": "1.0",
                "psr/http-message-implementation": "1.0"
            },
            "require-dev": {
                "bamarni/composer-bin-plugin": "^1.8.2",
                "http-interop/http-factory-tests": "0.9.0",
                "phpunit/phpunit": "^8.5.44 || ^9.6.25"
            },
            "suggest": {
                "laminas/laminas-httphandlerrunner": "Emit PSR-7 responses"
            },
            "type": "library",
            "extra": {
                "bamarni-bin": {
                    "bin-links": true,
                    "forward-command": false
                }
            },
            "autoload": {
                "psr-4": {
                    "GuzzleHttp\\Psr7\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Graham Campbell",
                    "email": "hello@gjcampbell.co.uk",
                    "homepage": "https://github.com/GrahamCampbell"
                },
                {
                    "name": "Michael Dowling",
                    "email": "mtdowling@gmail.com",
                    "homepage": "https://github.com/mtdowling"
                },
                {
                    "name": "George Mponos",
                    "email": "gmponos@gmail.com",
                    "homepage": "https://github.com/gmponos"
                },
                {
                    "name": "Tobias Nyholm",
                    "email": "tobias.nyholm@gmail.com",
                    "homepage": "https://github.com/Nyholm"
                },
                {
                    "name": "Márk Sági-Kazár",
                    "email": "mark.sagikazar@gmail.com",
                    "homepage": "https://github.com/sagikazarmark"
                },
                {
                    "name": "Tobias Schultze",
                    "email": "webmaster@tubo-world.de",
                    "homepage": "https://github.com/Tobion"
                },
                {
                    "name": "Márk Sági-Kazár",
                    "email": "mark.sagikazar@gmail.com",
                    "homepage": "https://sagikazarmark.hu"
                }
            ],
            "description": "PSR-7 message implementation that also provides common utility methods",
            "keywords": [
                "http",
                "message",
                "psr-7",
                "request",
                "response",
                "stream",
                "uri",
                "url"
            ],
            "support": {
                "issues": "https://github.com/guzzle/psr7/issues",
                "source": "https://github.com/guzzle/psr7/tree/2.8.0"
            },
            "funding": [
                {
                    "url": "https://github.com/GrahamCampbell",
                    "type": "github"
                },
                {
                    "url": "https://github.com/Nyholm",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/guzzlehttp/psr7",
                    "type": "tidelift"
                }
            ],
            "time": "2025-08-23T21:21:41+00:00"
        },
        {
            "name": "jean85/pretty-package-versions",
            "version": "2.1.1",
            "source": {
                "type": "git",
                "url": "https://github.com/Jean85/pretty-package-versions.git",
                "reference": "4d7aa5dab42e2a76d99559706022885de0e18e1a"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/Jean85/pretty-package-versions/zipball/4d7aa5dab42e2a76d99559706022885de0e18e1a",
                "reference": "4d7aa5dab42e2a76d99559706022885de0e18e1a",
                "shasum": ""
            },
            "require": {
                "composer-runtime-api": "^2.1.0",
                "php": "^7.4|^8.0"
            },
            "require-dev": {
                "friendsofphp/php-cs-fixer": "^3.2",
                "jean85/composer-provided-replaced-stub-package": "^1.0",
                "phpstan/phpstan": "^2.0",
                "phpunit/phpunit": "^7.5|^8.5|^9.6",
                "rector/rector": "^2.0",
                "vimeo/psalm": "^4.3 || ^5.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "1.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Jean85\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Alessandro Lai",
                    "email": "alessandro.lai85@gmail.com"
                }
            ],
            "description": "A library to get pretty versions strings of installed dependencies",
            "keywords": [
                "composer",
                "package",
                "release",
                "versions"
            ],
            "support": {
                "issues": "https://github.com/Jean85/pretty-package-versions/issues",
                "source": "https://github.com/Jean85/pretty-package-versions/tree/2.1.1"
            },
            "time": "2025-03-19T14:43:43+00:00"
        },
        {
            "name": "justinrainbow/json-schema",
            "version": "5.3.2",
            "source": {
                "type": "git",
                "url": "https://github.com/jsonrainbow/json-schema.git",
                "reference": "2f7abf648939847a789c55c206d4cb9dd0d53e2c"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/jsonrainbow/json-schema/zipball/2f7abf648939847a789c55c206d4cb9dd0d53e2c",
                "reference": "2f7abf648939847a789c55c206d4cb9dd0d53e2c",
                "shasum": ""
            },
            "require": {
                "php": ">=7.1"
            },
            "require-dev": {
                "friendsofphp/php-cs-fixer": "~2.2.20||~2.15.1",
                "json-schema/json-schema-test-suite": "1.2.0",
                "phpunit/phpunit": "^4.8.35"
            },
            "bin": [
                "bin/validate-json"
            ],
            "type": "library",
            "autoload": {
                "psr-4": {
                    "JsonSchema\\": "src/JsonSchema/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Bruno Prieto Reis",
                    "email": "bruno.p.reis@gmail.com"
                },
                {
                    "name": "Justin Rainbow",
                    "email": "justin.rainbow@gmail.com"
                },
                {
                    "name": "Igor Wiedler",
                    "email": "igor@wiedler.ch"
                },
                {
                    "name": "Robert Schönthal",
                    "email": "seroscho@googlemail.com"
                }
            ],
            "description": "A library to validate a json schema.",
            "homepage": "https://github.com/justinrainbow/json-schema",
            "keywords": [
                "json",
                "schema"
            ],
            "support": {
                "issues": "https://github.com/jsonrainbow/json-schema/issues",
                "source": "https://github.com/jsonrainbow/json-schema/tree/5.3.2"
            },
            "time": "2026-02-27T12:33:19+00:00"
        },
        {
            "name": "keradus/cli-executor",
            "version": "v2.3.0",
            "source": {
                "type": "git",
                "url": "https://github.com/PHP-CS-Fixer/cli-executor.git",
                "reference": "85c95a45a6a23e7d57f70b46de5fa1ffa55c5c66"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/PHP-CS-Fixer/cli-executor/zipball/85c95a45a6a23e7d57f70b46de5fa1ffa55c5c66",
                "reference": "85c95a45a6a23e7d57f70b46de5fa1ffa55c5c66",
                "shasum": ""
            },
            "require": {
                "php": "^7.4 || ^8.0",
                "symfony/process": "^5.4 || ^6.4 || ^7.3 || ^8.0"
            },
            "require-dev": {
                "friendsofphp/php-cs-fixer": "^3.89",
                "maglnet/composer-require-checker": "^3.8 || ^4.18",
                "phpunit/phpunit": "^9.6.22 || ^10.5.58 || ^11.5.43"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Keradus\\CliExecutor\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Dariusz Rumiński",
                    "email": "dariusz.ruminski@gmail.com"
                }
            ],
            "description": "CLI execution wrapper",
            "support": {
                "issues": "https://github.com/PHP-CS-Fixer/cli-executor/issues",
                "source": "https://github.com/PHP-CS-Fixer/cli-executor/tree/v2.3.0"
            },
            "time": "2025-11-05T20:21:23+00:00"
        },
        {
            "name": "mikey179/vfsstream",
            "version": "v1.6.12",
            "source": {
                "type": "git",
                "url": "https://github.com/bovigo/vfsStream.git",
                "reference": "fe695ec993e0a55c3abdda10a9364eb31c6f1bf0"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/bovigo/vfsStream/zipball/fe695ec993e0a55c3abdda10a9364eb31c6f1bf0",
                "reference": "fe695ec993e0a55c3abdda10a9364eb31c6f1bf0",
                "shasum": ""
            },
            "require": {
                "php": ">=7.1.0"
            },
            "require-dev": {
                "phpunit/phpunit": "^7.5||^8.5||^9.6",
                "yoast/phpunit-polyfills": "^2.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "1.6.x-dev"
                }
            },
            "autoload": {
                "psr-0": {
                    "org\\bovigo\\vfs\\": "src/main/php"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Frank Kleine",
                    "homepage": "http://frankkleine.de/",
                    "role": "Developer"
                }
            ],
            "description": "Virtual file system to mock the real file system in unit tests.",
            "homepage": "http://vfs.bovigo.org/",
            "support": {
                "issues": "https://github.com/bovigo/vfsStream/issues",
                "source": "https://github.com/bovigo/vfsStream/tree/master",
                "wiki": "https://github.com/bovigo/vfsStream/wiki"
            },
            "time": "2024-08-29T18:43:31+00:00"
        },
        {
            "name": "myclabs/deep-copy",
            "version": "1.13.4",
            "source": {
                "type": "git",
                "url": "https://github.com/myclabs/DeepCopy.git",
                "reference": "07d290f0c47959fd5eed98c95ee5602db07e0b6a"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/myclabs/DeepCopy/zipball/07d290f0c47959fd5eed98c95ee5602db07e0b6a",
                "reference": "07d290f0c47959fd5eed98c95ee5602db07e0b6a",
                "shasum": ""
            },
            "require": {
                "php": "^7.1 || ^8.0"
            },
            "conflict": {
                "doctrine/collections": "<1.6.8",
                "doctrine/common": "<2.13.3 || >=3 <3.2.2"
            },
            "require-dev": {
                "doctrine/collections": "^1.6.8",
                "doctrine/common": "^2.13.3 || ^3.2.2",
                "phpspec/prophecy": "^1.10",
                "phpunit/phpunit": "^7.5.20 || ^8.5.23 || ^9.5.13"
            },
            "type": "library",
            "autoload": {
                "files": [
                    "src/DeepCopy/deep_copy.php"
                ],
                "psr-4": {
                    "DeepCopy\\": "src/DeepCopy/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "description": "Create deep copies (clones) of your objects",
            "keywords": [
                "clone",
                "copy",
                "duplicate",
                "object",
                "object graph"
            ],
            "support": {
                "issues": "https://github.com/myclabs/DeepCopy/issues",
                "source": "https://github.com/myclabs/DeepCopy/tree/1.13.4"
            },
            "funding": [
                {
                    "url": "https://tidelift.com/funding/github/packagist/myclabs/deep-copy",
                    "type": "tidelift"
                }
            ],
            "time": "2025-08-01T08:46:24+00:00"
        },
        {
            "name": "nikic/php-parser",
            "version": "v5.7.0",
            "source": {
                "type": "git",
                "url": "https://github.com/nikic/PHP-Parser.git",
                "reference": "dca41cd15c2ac9d055ad70dbfd011130757d1f82"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/nikic/PHP-Parser/zipball/dca41cd15c2ac9d055ad70dbfd011130757d1f82",
                "reference": "dca41cd15c2ac9d055ad70dbfd011130757d1f82",
                "shasum": ""
            },
            "require": {
                "ext-ctype": "*",
                "ext-json": "*",
                "ext-tokenizer": "*",
                "php": ">=7.4"
            },
            "require-dev": {
                "ircmaxell/php-yacc": "^0.0.7",
                "phpunit/phpunit": "^9.0"
            },
            "bin": [
                "bin/php-parse"
            ],
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "5.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "PhpParser\\": "lib/PhpParser"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Nikita Popov"
                }
            ],
            "description": "A PHP parser written in PHP",
            "keywords": [
                "parser",
                "php"
            ],
            "support": {
                "issues": "https://github.com/nikic/PHP-Parser/issues",
                "source": "https://github.com/nikic/PHP-Parser/tree/v5.7.0"
            },
            "time": "2025-12-06T11:56:16+00:00"
        },
        {
            "name": "phar-io/manifest",
            "version": "2.0.4",
            "source": {
                "type": "git",
                "url": "https://github.com/phar-io/manifest.git",
                "reference": "54750ef60c58e43759730615a392c31c80e23176"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/phar-io/manifest/zipball/54750ef60c58e43759730615a392c31c80e23176",
                "reference": "54750ef60c58e43759730615a392c31c80e23176",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-libxml": "*",
                "ext-phar": "*",
                "ext-xmlwriter": "*",
                "phar-io/version": "^3.0.1",
                "php": "^7.2 || ^8.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "2.0.x-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Arne Blankerts",
                    "email": "arne@blankerts.de",
                    "role": "Developer"
                },
                {
                    "name": "Sebastian Heuer",
                    "email": "sebastian@phpeople.de",
                    "role": "Developer"
                },
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "Developer"
                }
            ],
            "description": "Component for reading phar.io manifest information from a PHP Archive (PHAR)",
            "support": {
                "issues": "https://github.com/phar-io/manifest/issues",
                "source": "https://github.com/phar-io/manifest/tree/2.0.4"
            },
            "funding": [
                {
                    "url": "https://github.com/theseer",
                    "type": "github"
                }
            ],
            "time": "2024-03-03T12:33:53+00:00"
        },
        {
            "name": "phar-io/version",
            "version": "3.2.1",
            "source": {
                "type": "git",
                "url": "https://github.com/phar-io/version.git",
                "reference": "4f7fd7836c6f332bb2933569e566a0d6c4cbed74"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/phar-io/version/zipball/4f7fd7836c6f332bb2933569e566a0d6c4cbed74",
                "reference": "4f7fd7836c6f332bb2933569e566a0d6c4cbed74",
                "shasum": ""
            },
            "require": {
                "php": "^7.2 || ^8.0"
            },
            "type": "library",
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Arne Blankerts",
                    "email": "arne@blankerts.de",
                    "role": "Developer"
                },
                {
                    "name": "Sebastian Heuer",
                    "email": "sebastian@phpeople.de",
                    "role": "Developer"
                },
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "Developer"
                }
            ],
            "description": "Library for handling version information and constraints",
            "support": {
                "issues": "https://github.com/phar-io/version/issues",
                "source": "https://github.com/phar-io/version/tree/3.2.1"
            },
            "time": "2022-02-21T01:04:05+00:00"
        },
        {
            "name": "php-coveralls/php-coveralls",
            "version": "v2.9.1",
            "source": {
                "type": "git",
                "url": "https://github.com/php-coveralls/php-coveralls.git",
                "reference": "916bdb118597f61ce6715fb738ab8f234b89a2cb"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-coveralls/php-coveralls/zipball/916bdb118597f61ce6715fb738ab8f234b89a2cb",
                "reference": "916bdb118597f61ce6715fb738ab8f234b89a2cb",
                "shasum": ""
            },
            "require": {
                "ext-json": "*",
                "ext-simplexml": "*",
                "guzzlehttp/guzzle": "^6.0 || ^7.0",
                "php": "^7.4 || ^8.0",
                "psr/log": "^1.0 || ^2.0 || ^3.0",
                "symfony/config": "^5.4 || ^6.4 || ^7.0 || ^8.0",
                "symfony/console": "^5.4 || ^6.4 || ^7.0 || ^8.0",
                "symfony/stopwatch": "^5.4 || ^6.4 || ^7.0 || ^8.0",
                "symfony/yaml": "^5.4 || ^6.4 || ^7.0 || ^8.0"
            },
            "require-dev": {
                "phpspec/prophecy-phpunit": "^2.4",
                "phpunit/phpunit": "^9.6.29 || ^10.5.58 || ^11.5.43"
            },
            "suggest": {
                "symfony/http-kernel": "Allows Symfony integration"
            },
            "bin": [
                "bin/php-coveralls"
            ],
            "type": "library",
            "autoload": {
                "psr-4": {
                    "PhpCoveralls\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Kitamura Satoshi",
                    "email": "with.no.parachute@gmail.com",
                    "homepage": "https://www.facebook.com/satooshi.jp",
                    "role": "Original creator"
                },
                {
                    "name": "Takashi Matsuo",
                    "email": "tmatsuo@google.com"
                },
                {
                    "name": "Google Inc"
                },
                {
                    "name": "Dariusz Ruminski",
                    "email": "dariusz.ruminski@gmail.com",
                    "homepage": "https://github.com/keradus"
                },
                {
                    "name": "Contributors",
                    "homepage": "https://github.com/php-coveralls/php-coveralls/graphs/contributors"
                }
            ],
            "description": "PHP client library for Coveralls API",
            "homepage": "https://github.com/php-coveralls/php-coveralls",
            "keywords": [
                "ci",
                "coverage",
                "github",
                "test"
            ],
            "support": {
                "issues": "https://github.com/php-coveralls/php-coveralls/issues",
                "source": "https://github.com/php-coveralls/php-coveralls/tree/v2.9.1"
            },
            "time": "2025-12-18T13:08:37+00:00"
        },
        {
            "name": "php-cs-fixer/accessible-object",
            "version": "v1.2.0",
            "source": {
                "type": "git",
                "url": "https://github.com/PHP-CS-Fixer/AccessibleObject.git",
                "reference": "5f77857a0fedf1a24b4877de2852338b3b2f4433"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/PHP-CS-Fixer/AccessibleObject/zipball/5f77857a0fedf1a24b4877de2852338b3b2f4433",
                "reference": "5f77857a0fedf1a24b4877de2852338b3b2f4433",
                "shasum": ""
            },
            "require": {
                "php": "^5.6 || ^7.0 || ^8.0"
            },
            "require-dev": {
                "phpunit/phpunit": "^9.6.24 || ^10.5.52 || ^11.5.33"
            },
            "type": "application",
            "autoload": {
                "psr-4": {
                    "PhpCsFixer\\AccessibleObject\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Dariusz Rumiński",
                    "email": "dariusz.ruminski@gmail.com"
                }
            ],
            "description": "A library to reveal object internals.",
            "support": {
                "issues": "https://github.com/PHP-CS-Fixer/AccessibleObject/issues",
                "source": "https://github.com/PHP-CS-Fixer/AccessibleObject/tree/v1.2.0"
            },
            "time": "2025-08-20T20:33:51+00:00"
        },
        {
            "name": "php-cs-fixer/phpunit-constraint-isidenticalstring",
            "version": "v1.8.0",
            "source": {
                "type": "git",
                "url": "https://github.com/PHP-CS-Fixer/phpunit-constraint-isidenticalstring.git",
                "reference": "b5e374ed4ddd15c3fc1baccb514f6a1c1093fa4c"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/PHP-CS-Fixer/phpunit-constraint-isidenticalstring/zipball/b5e374ed4ddd15c3fc1baccb514f6a1c1093fa4c",
                "reference": "b5e374ed4ddd15c3fc1baccb514f6a1c1093fa4c",
                "shasum": ""
            },
            "require": {
                "php": "^7.4 || ^8.0",
                "phpunit/phpunit": "^9.6.34 || ^10.5.53 || ^11.5.55 || ^12.5.14 || ^13.0.5"
            },
            "type": "library",
            "autoload": {
                "files": [
                    "src/Constraint/IsIdenticalString.php"
                ],
                "psr-4": {
                    "PhpCsFixer\\PhpunitConstraintIsIdenticalString\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Dariusz Rumiński",
                    "email": "dariusz.ruminski@gmail.com"
                }
            ],
            "description": "Constraint for testing strings considering not-same line endings.",
            "support": {
                "issues": "https://github.com/PHP-CS-Fixer/phpunit-constraint-isidenticalstring/issues",
                "source": "https://github.com/PHP-CS-Fixer/phpunit-constraint-isidenticalstring/tree/v1.8.0"
            },
            "time": "2026-02-26T12:12:06+00:00"
        },
        {
            "name": "php-cs-fixer/phpunit-constraint-xmlmatchesxsd",
            "version": "v1.8.0",
            "source": {
                "type": "git",
                "url": "https://github.com/PHP-CS-Fixer/phpunit-constraint-xmlmatchesxsd.git",
                "reference": "a08211257f128fa4673390df5776ec2797540565"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/PHP-CS-Fixer/phpunit-constraint-xmlmatchesxsd/zipball/a08211257f128fa4673390df5776ec2797540565",
                "reference": "a08211257f128fa4673390df5776ec2797540565",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-libxml": "*",
                "php": "^7.4 || ^8.0",
                "phpunit/phpunit": "^9.6.34 || ^10.5.53 || ^11.5.55 || ^12.5.14 || ^13.0.5"
            },
            "type": "library",
            "autoload": {
                "files": [
                    "src/Constraint/XmlMatchesXsd.php"
                ],
                "psr-4": {
                    "PhpCsFixer\\PhpunitConstraintXmlMatchesXsd\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "SpacePossum"
                },
                {
                    "name": "Dariusz Rumiński",
                    "email": "dariusz.ruminski@gmail.com"
                }
            ],
            "description": "Constraint for testing XML against XSD.",
            "support": {
                "issues": "https://github.com/PHP-CS-Fixer/phpunit-constraint-xmlmatchesxsd/issues",
                "source": "https://github.com/PHP-CS-Fixer/phpunit-constraint-xmlmatchesxsd/tree/v1.8.0"
            },
            "time": "2026-02-26T12:12:03+00:00"
        },
        {
            "name": "phpunit/php-code-coverage",
            "version": "10.1.16",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/php-code-coverage.git",
                "reference": "7e308268858ed6baedc8704a304727d20bc07c77"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/php-code-coverage/zipball/7e308268858ed6baedc8704a304727d20bc07c77",
                "reference": "7e308268858ed6baedc8704a304727d20bc07c77",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-libxml": "*",
                "ext-xmlwriter": "*",
                "nikic/php-parser": "^4.19.1 || ^5.1.0",
                "php": ">=8.1",
                "phpunit/php-file-iterator": "^4.1.0",
                "phpunit/php-text-template": "^3.0.1",
                "sebastian/code-unit-reverse-lookup": "^3.0.0",
                "sebastian/complexity": "^3.2.0",
                "sebastian/environment": "^6.1.0",
                "sebastian/lines-of-code": "^2.0.2",
                "sebastian/version": "^4.0.1",
                "theseer/tokenizer": "^1.2.3"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.1"
            },
            "suggest": {
                "ext-pcov": "PHP extension that provides line coverage",
                "ext-xdebug": "PHP extension that provides line coverage as well as branch and path coverage"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "10.1.x-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Library that provides collection, processing, and rendering functionality for PHP code coverage information.",
            "homepage": "https://github.com/sebastianbergmann/php-code-coverage",
            "keywords": [
                "coverage",
                "testing",
                "xunit"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/php-code-coverage/issues",
                "security": "https://github.com/sebastianbergmann/php-code-coverage/security/policy",
                "source": "https://github.com/sebastianbergmann/php-code-coverage/tree/10.1.16"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2024-08-22T04:31:57+00:00"
        },
        {
            "name": "phpunit/php-file-iterator",
            "version": "4.1.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/php-file-iterator.git",
                "reference": "a95037b6d9e608ba092da1b23931e537cadc3c3c"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/php-file-iterator/zipball/a95037b6d9e608ba092da1b23931e537cadc3c3c",
                "reference": "a95037b6d9e608ba092da1b23931e537cadc3c3c",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "4.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "FilterIterator implementation that filters files based on a list of suffixes.",
            "homepage": "https://github.com/sebastianbergmann/php-file-iterator/",
            "keywords": [
                "filesystem",
                "iterator"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/php-file-iterator/issues",
                "security": "https://github.com/sebastianbergmann/php-file-iterator/security/policy",
                "source": "https://github.com/sebastianbergmann/php-file-iterator/tree/4.1.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-08-31T06:24:48+00:00"
        },
        {
            "name": "phpunit/php-invoker",
            "version": "4.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/php-invoker.git",
                "reference": "f5e568ba02fa5ba0ddd0f618391d5a9ea50b06d7"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/php-invoker/zipball/f5e568ba02fa5ba0ddd0f618391d5a9ea50b06d7",
                "reference": "f5e568ba02fa5ba0ddd0f618391d5a9ea50b06d7",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "ext-pcntl": "*",
                "phpunit/phpunit": "^10.0"
            },
            "suggest": {
                "ext-pcntl": "*"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "4.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Invoke callables with a timeout",
            "homepage": "https://github.com/sebastianbergmann/php-invoker/",
            "keywords": [
                "process"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/php-invoker/issues",
                "source": "https://github.com/sebastianbergmann/php-invoker/tree/4.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T06:56:09+00:00"
        },
        {
            "name": "phpunit/php-text-template",
            "version": "3.0.1",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/php-text-template.git",
                "reference": "0c7b06ff49e3d5072f057eb1fa59258bf287a748"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/php-text-template/zipball/0c7b06ff49e3d5072f057eb1fa59258bf287a748",
                "reference": "0c7b06ff49e3d5072f057eb1fa59258bf287a748",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "3.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Simple template engine.",
            "homepage": "https://github.com/sebastianbergmann/php-text-template/",
            "keywords": [
                "template"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/php-text-template/issues",
                "security": "https://github.com/sebastianbergmann/php-text-template/security/policy",
                "source": "https://github.com/sebastianbergmann/php-text-template/tree/3.0.1"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-08-31T14:07:24+00:00"
        },
        {
            "name": "phpunit/php-timer",
            "version": "6.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/php-timer.git",
                "reference": "e2a2d67966e740530f4a3343fe2e030ffdc1161d"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/php-timer/zipball/e2a2d67966e740530f4a3343fe2e030ffdc1161d",
                "reference": "e2a2d67966e740530f4a3343fe2e030ffdc1161d",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "6.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Utility class for timing",
            "homepage": "https://github.com/sebastianbergmann/php-timer/",
            "keywords": [
                "timer"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/php-timer/issues",
                "source": "https://github.com/sebastianbergmann/php-timer/tree/6.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T06:57:52+00:00"
        },
        {
            "name": "phpunit/phpunit",
            "version": "10.5.63",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/phpunit.git",
                "reference": "33198268dad71e926626b618f3ec3966661e4d90"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/phpunit/zipball/33198268dad71e926626b618f3ec3966661e4d90",
                "reference": "33198268dad71e926626b618f3ec3966661e4d90",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-json": "*",
                "ext-libxml": "*",
                "ext-mbstring": "*",
                "ext-xml": "*",
                "ext-xmlwriter": "*",
                "myclabs/deep-copy": "^1.13.4",
                "phar-io/manifest": "^2.0.4",
                "phar-io/version": "^3.2.1",
                "php": ">=8.1",
                "phpunit/php-code-coverage": "^10.1.16",
                "phpunit/php-file-iterator": "^4.1.0",
                "phpunit/php-invoker": "^4.0.0",
                "phpunit/php-text-template": "^3.0.1",
                "phpunit/php-timer": "^6.0.0",
                "sebastian/cli-parser": "^2.0.1",
                "sebastian/code-unit": "^2.0.0",
                "sebastian/comparator": "^5.0.5",
                "sebastian/diff": "^5.1.1",
                "sebastian/environment": "^6.1.0",
                "sebastian/exporter": "^5.1.4",
                "sebastian/global-state": "^6.0.2",
                "sebastian/object-enumerator": "^5.0.0",
                "sebastian/recursion-context": "^5.0.1",
                "sebastian/type": "^4.0.0",
                "sebastian/version": "^4.0.1"
            },
            "suggest": {
                "ext-soap": "To be able to generate mocks based on WSDL files"
            },
            "bin": [
                "phpunit"
            ],
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "10.5-dev"
                }
            },
            "autoload": {
                "files": [
                    "src/Framework/Assert/Functions.php"
                ],
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "The PHP Unit Testing framework.",
            "homepage": "https://phpunit.de/",
            "keywords": [
                "phpunit",
                "testing",
                "xunit"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/phpunit/issues",
                "security": "https://github.com/sebastianbergmann/phpunit/security/policy",
                "source": "https://github.com/sebastianbergmann/phpunit/tree/10.5.63"
            },
            "funding": [
                {
                    "url": "https://phpunit.de/sponsors.html",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                },
                {
                    "url": "https://liberapay.com/sebastianbergmann",
                    "type": "liberapay"
                },
                {
                    "url": "https://thanks.dev/u/gh/sebastianbergmann",
                    "type": "thanks_dev"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/phpunit/phpunit",
                    "type": "tidelift"
                }
            ],
            "time": "2026-01-27T05:48:37+00:00"
        },
        {
            "name": "psr/http-client",
            "version": "1.0.3",
            "source": {
                "type": "git",
                "url": "https://github.com/php-fig/http-client.git",
                "reference": "bb5906edc1c324c9a05aa0873d40117941e5fa90"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-fig/http-client/zipball/bb5906edc1c324c9a05aa0873d40117941e5fa90",
                "reference": "bb5906edc1c324c9a05aa0873d40117941e5fa90",
                "shasum": ""
            },
            "require": {
                "php": "^7.0 || ^8.0",
                "psr/http-message": "^1.0 || ^2.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "1.0.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Psr\\Http\\Client\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "PHP-FIG",
                    "homepage": "https://www.php-fig.org/"
                }
            ],
            "description": "Common interface for HTTP clients",
            "homepage": "https://github.com/php-fig/http-client",
            "keywords": [
                "http",
                "http-client",
                "psr",
                "psr-18"
            ],
            "support": {
                "source": "https://github.com/php-fig/http-client"
            },
            "time": "2023-09-23T14:17:50+00:00"
        },
        {
            "name": "psr/http-factory",
            "version": "1.1.0",
            "source": {
                "type": "git",
                "url": "https://github.com/php-fig/http-factory.git",
                "reference": "2b4765fddfe3b508ac62f829e852b1501d3f6e8a"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-fig/http-factory/zipball/2b4765fddfe3b508ac62f829e852b1501d3f6e8a",
                "reference": "2b4765fddfe3b508ac62f829e852b1501d3f6e8a",
                "shasum": ""
            },
            "require": {
                "php": ">=7.1",
                "psr/http-message": "^1.0 || ^2.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "1.0.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Psr\\Http\\Message\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "PHP-FIG",
                    "homepage": "https://www.php-fig.org/"
                }
            ],
            "description": "PSR-17: Common interfaces for PSR-7 HTTP message factories",
            "keywords": [
                "factory",
                "http",
                "message",
                "psr",
                "psr-17",
                "psr-7",
                "request",
                "response"
            ],
            "support": {
                "source": "https://github.com/php-fig/http-factory"
            },
            "time": "2024-04-15T12:06:14+00:00"
        },
        {
            "name": "psr/http-message",
            "version": "2.0",
            "source": {
                "type": "git",
                "url": "https://github.com/php-fig/http-message.git",
                "reference": "402d35bcb92c70c026d1a6a9883f06b2ead23d71"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/php-fig/http-message/zipball/402d35bcb92c70c026d1a6a9883f06b2ead23d71",
                "reference": "402d35bcb92c70c026d1a6a9883f06b2ead23d71",
                "shasum": ""
            },
            "require": {
                "php": "^7.2 || ^8.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-master": "2.0.x-dev"
                }
            },
            "autoload": {
                "psr-4": {
                    "Psr\\Http\\Message\\": "src/"
                }
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "PHP-FIG",
                    "homepage": "https://www.php-fig.org/"
                }
            ],
            "description": "Common interface for HTTP messages",
            "homepage": "https://github.com/php-fig/http-message",
            "keywords": [
                "http",
                "http-message",
                "psr",
                "psr-7",
                "request",
                "response"
            ],
            "support": {
                "source": "https://github.com/php-fig/http-message/tree/2.0"
            },
            "time": "2023-04-04T09:54:51+00:00"
        },
        {
            "name": "ralouphie/getallheaders",
            "version": "3.0.3",
            "source": {
                "type": "git",
                "url": "https://github.com/ralouphie/getallheaders.git",
                "reference": "120b605dfeb996808c31b6477290a714d356e822"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/ralouphie/getallheaders/zipball/120b605dfeb996808c31b6477290a714d356e822",
                "reference": "120b605dfeb996808c31b6477290a714d356e822",
                "shasum": ""
            },
            "require": {
                "php": ">=5.6"
            },
            "require-dev": {
                "php-coveralls/php-coveralls": "^2.1",
                "phpunit/phpunit": "^5 || ^6.5"
            },
            "type": "library",
            "autoload": {
                "files": [
                    "src/getallheaders.php"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Ralph Khattar",
                    "email": "ralph.khattar@gmail.com"
                }
            ],
            "description": "A polyfill for getallheaders.",
            "support": {
                "issues": "https://github.com/ralouphie/getallheaders/issues",
                "source": "https://github.com/ralouphie/getallheaders/tree/develop"
            },
            "time": "2019-03-08T08:55:37+00:00"
        },
        {
            "name": "sebastian/cli-parser",
            "version": "2.0.1",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/cli-parser.git",
                "reference": "c34583b87e7b7a8055bf6c450c2c77ce32a24084"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/cli-parser/zipball/c34583b87e7b7a8055bf6c450c2c77ce32a24084",
                "reference": "c34583b87e7b7a8055bf6c450c2c77ce32a24084",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "2.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Library for parsing CLI options",
            "homepage": "https://github.com/sebastianbergmann/cli-parser",
            "support": {
                "issues": "https://github.com/sebastianbergmann/cli-parser/issues",
                "security": "https://github.com/sebastianbergmann/cli-parser/security/policy",
                "source": "https://github.com/sebastianbergmann/cli-parser/tree/2.0.1"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2024-03-02T07:12:49+00:00"
        },
        {
            "name": "sebastian/code-unit",
            "version": "2.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/code-unit.git",
                "reference": "a81fee9eef0b7a76af11d121767abc44c104e503"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/code-unit/zipball/a81fee9eef0b7a76af11d121767abc44c104e503",
                "reference": "a81fee9eef0b7a76af11d121767abc44c104e503",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "2.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Collection of value objects that represent the PHP code units",
            "homepage": "https://github.com/sebastianbergmann/code-unit",
            "support": {
                "issues": "https://github.com/sebastianbergmann/code-unit/issues",
                "source": "https://github.com/sebastianbergmann/code-unit/tree/2.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T06:58:43+00:00"
        },
        {
            "name": "sebastian/code-unit-reverse-lookup",
            "version": "3.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/code-unit-reverse-lookup.git",
                "reference": "5e3a687f7d8ae33fb362c5c0743794bbb2420a1d"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/code-unit-reverse-lookup/zipball/5e3a687f7d8ae33fb362c5c0743794bbb2420a1d",
                "reference": "5e3a687f7d8ae33fb362c5c0743794bbb2420a1d",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "3.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                }
            ],
            "description": "Looks up which function or method a line of code belongs to",
            "homepage": "https://github.com/sebastianbergmann/code-unit-reverse-lookup/",
            "support": {
                "issues": "https://github.com/sebastianbergmann/code-unit-reverse-lookup/issues",
                "source": "https://github.com/sebastianbergmann/code-unit-reverse-lookup/tree/3.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T06:59:15+00:00"
        },
        {
            "name": "sebastian/comparator",
            "version": "5.0.5",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/comparator.git",
                "reference": "55dfef806eb7dfeb6e7a6935601fef866f8ca48d"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/comparator/zipball/55dfef806eb7dfeb6e7a6935601fef866f8ca48d",
                "reference": "55dfef806eb7dfeb6e7a6935601fef866f8ca48d",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-mbstring": "*",
                "php": ">=8.1",
                "sebastian/diff": "^5.0",
                "sebastian/exporter": "^5.0"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.5"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "5.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                },
                {
                    "name": "Jeff Welch",
                    "email": "whatthejeff@gmail.com"
                },
                {
                    "name": "Volker Dusch",
                    "email": "github@wallbash.com"
                },
                {
                    "name": "Bernhard Schussek",
                    "email": "bschussek@2bepublished.at"
                }
            ],
            "description": "Provides the functionality to compare PHP values for equality",
            "homepage": "https://github.com/sebastianbergmann/comparator",
            "keywords": [
                "comparator",
                "compare",
                "equality"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/comparator/issues",
                "security": "https://github.com/sebastianbergmann/comparator/security/policy",
                "source": "https://github.com/sebastianbergmann/comparator/tree/5.0.5"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                },
                {
                    "url": "https://liberapay.com/sebastianbergmann",
                    "type": "liberapay"
                },
                {
                    "url": "https://thanks.dev/u/gh/sebastianbergmann",
                    "type": "thanks_dev"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/sebastian/comparator",
                    "type": "tidelift"
                }
            ],
            "time": "2026-01-24T09:25:16+00:00"
        },
        {
            "name": "sebastian/complexity",
            "version": "3.2.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/complexity.git",
                "reference": "68ff824baeae169ec9f2137158ee529584553799"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/complexity/zipball/68ff824baeae169ec9f2137158ee529584553799",
                "reference": "68ff824baeae169ec9f2137158ee529584553799",
                "shasum": ""
            },
            "require": {
                "nikic/php-parser": "^4.18 || ^5.0",
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "3.2-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Library for calculating the complexity of PHP code units",
            "homepage": "https://github.com/sebastianbergmann/complexity",
            "support": {
                "issues": "https://github.com/sebastianbergmann/complexity/issues",
                "security": "https://github.com/sebastianbergmann/complexity/security/policy",
                "source": "https://github.com/sebastianbergmann/complexity/tree/3.2.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-12-21T08:37:17+00:00"
        },
        {
            "name": "sebastian/environment",
            "version": "6.1.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/environment.git",
                "reference": "8074dbcd93529b357029f5cc5058fd3e43666984"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/environment/zipball/8074dbcd93529b357029f5cc5058fd3e43666984",
                "reference": "8074dbcd93529b357029f5cc5058fd3e43666984",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "suggest": {
                "ext-posix": "*"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "6.1-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                }
            ],
            "description": "Provides functionality to handle HHVM/PHP environments",
            "homepage": "https://github.com/sebastianbergmann/environment",
            "keywords": [
                "Xdebug",
                "environment",
                "hhvm"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/environment/issues",
                "security": "https://github.com/sebastianbergmann/environment/security/policy",
                "source": "https://github.com/sebastianbergmann/environment/tree/6.1.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2024-03-23T08:47:14+00:00"
        },
        {
            "name": "sebastian/exporter",
            "version": "5.1.4",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/exporter.git",
                "reference": "0735b90f4da94969541dac1da743446e276defa6"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/exporter/zipball/0735b90f4da94969541dac1da743446e276defa6",
                "reference": "0735b90f4da94969541dac1da743446e276defa6",
                "shasum": ""
            },
            "require": {
                "ext-mbstring": "*",
                "php": ">=8.1",
                "sebastian/recursion-context": "^5.0"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.5"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "5.1-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                },
                {
                    "name": "Jeff Welch",
                    "email": "whatthejeff@gmail.com"
                },
                {
                    "name": "Volker Dusch",
                    "email": "github@wallbash.com"
                },
                {
                    "name": "Adam Harvey",
                    "email": "aharvey@php.net"
                },
                {
                    "name": "Bernhard Schussek",
                    "email": "bschussek@gmail.com"
                }
            ],
            "description": "Provides the functionality to export PHP variables for visualization",
            "homepage": "https://www.github.com/sebastianbergmann/exporter",
            "keywords": [
                "export",
                "exporter"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/exporter/issues",
                "security": "https://github.com/sebastianbergmann/exporter/security/policy",
                "source": "https://github.com/sebastianbergmann/exporter/tree/5.1.4"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                },
                {
                    "url": "https://liberapay.com/sebastianbergmann",
                    "type": "liberapay"
                },
                {
                    "url": "https://thanks.dev/u/gh/sebastianbergmann",
                    "type": "thanks_dev"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/sebastian/exporter",
                    "type": "tidelift"
                }
            ],
            "time": "2025-09-24T06:09:11+00:00"
        },
        {
            "name": "sebastian/global-state",
            "version": "6.0.2",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/global-state.git",
                "reference": "987bafff24ecc4c9ac418cab1145b96dd6e9cbd9"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/global-state/zipball/987bafff24ecc4c9ac418cab1145b96dd6e9cbd9",
                "reference": "987bafff24ecc4c9ac418cab1145b96dd6e9cbd9",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1",
                "sebastian/object-reflector": "^3.0",
                "sebastian/recursion-context": "^5.0"
            },
            "require-dev": {
                "ext-dom": "*",
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "6.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                }
            ],
            "description": "Snapshotting of global state",
            "homepage": "https://www.github.com/sebastianbergmann/global-state",
            "keywords": [
                "global state"
            ],
            "support": {
                "issues": "https://github.com/sebastianbergmann/global-state/issues",
                "security": "https://github.com/sebastianbergmann/global-state/security/policy",
                "source": "https://github.com/sebastianbergmann/global-state/tree/6.0.2"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2024-03-02T07:19:19+00:00"
        },
        {
            "name": "sebastian/lines-of-code",
            "version": "2.0.2",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/lines-of-code.git",
                "reference": "856e7f6a75a84e339195d48c556f23be2ebf75d0"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/lines-of-code/zipball/856e7f6a75a84e339195d48c556f23be2ebf75d0",
                "reference": "856e7f6a75a84e339195d48c556f23be2ebf75d0",
                "shasum": ""
            },
            "require": {
                "nikic/php-parser": "^4.18 || ^5.0",
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "2.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Library for counting the lines of code in PHP source code",
            "homepage": "https://github.com/sebastianbergmann/lines-of-code",
            "support": {
                "issues": "https://github.com/sebastianbergmann/lines-of-code/issues",
                "security": "https://github.com/sebastianbergmann/lines-of-code/security/policy",
                "source": "https://github.com/sebastianbergmann/lines-of-code/tree/2.0.2"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-12-21T08:38:20+00:00"
        },
        {
            "name": "sebastian/object-enumerator",
            "version": "5.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/object-enumerator.git",
                "reference": "202d0e344a580d7f7d04b3fafce6933e59dae906"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/object-enumerator/zipball/202d0e344a580d7f7d04b3fafce6933e59dae906",
                "reference": "202d0e344a580d7f7d04b3fafce6933e59dae906",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1",
                "sebastian/object-reflector": "^3.0",
                "sebastian/recursion-context": "^5.0"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "5.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                }
            ],
            "description": "Traverses array structures and object graphs to enumerate all referenced objects",
            "homepage": "https://github.com/sebastianbergmann/object-enumerator/",
            "support": {
                "issues": "https://github.com/sebastianbergmann/object-enumerator/issues",
                "source": "https://github.com/sebastianbergmann/object-enumerator/tree/5.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T07:08:32+00:00"
        },
        {
            "name": "sebastian/object-reflector",
            "version": "3.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/object-reflector.git",
                "reference": "24ed13d98130f0e7122df55d06c5c4942a577957"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/object-reflector/zipball/24ed13d98130f0e7122df55d06c5c4942a577957",
                "reference": "24ed13d98130f0e7122df55d06c5c4942a577957",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "3.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                }
            ],
            "description": "Allows reflection of object attributes, including inherited and non-public ones",
            "homepage": "https://github.com/sebastianbergmann/object-reflector/",
            "support": {
                "issues": "https://github.com/sebastianbergmann/object-reflector/issues",
                "source": "https://github.com/sebastianbergmann/object-reflector/tree/3.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T07:06:18+00:00"
        },
        {
            "name": "sebastian/recursion-context",
            "version": "5.0.1",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/recursion-context.git",
                "reference": "47e34210757a2f37a97dcd207d032e1b01e64c7a"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/recursion-context/zipball/47e34210757a2f37a97dcd207d032e1b01e64c7a",
                "reference": "47e34210757a2f37a97dcd207d032e1b01e64c7a",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.5"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "5.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de"
                },
                {
                    "name": "Jeff Welch",
                    "email": "whatthejeff@gmail.com"
                },
                {
                    "name": "Adam Harvey",
                    "email": "aharvey@php.net"
                }
            ],
            "description": "Provides functionality to recursively process PHP variables",
            "homepage": "https://github.com/sebastianbergmann/recursion-context",
            "support": {
                "issues": "https://github.com/sebastianbergmann/recursion-context/issues",
                "security": "https://github.com/sebastianbergmann/recursion-context/security/policy",
                "source": "https://github.com/sebastianbergmann/recursion-context/tree/5.0.1"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                },
                {
                    "url": "https://liberapay.com/sebastianbergmann",
                    "type": "liberapay"
                },
                {
                    "url": "https://thanks.dev/u/gh/sebastianbergmann",
                    "type": "thanks_dev"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/sebastian/recursion-context",
                    "type": "tidelift"
                }
            ],
            "time": "2025-08-10T07:50:56+00:00"
        },
        {
            "name": "sebastian/type",
            "version": "4.0.0",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/type.git",
                "reference": "462699a16464c3944eefc02ebdd77882bd3925bf"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/type/zipball/462699a16464c3944eefc02ebdd77882bd3925bf",
                "reference": "462699a16464c3944eefc02ebdd77882bd3925bf",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "require-dev": {
                "phpunit/phpunit": "^10.0"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "4.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Collection of value objects that represent the types of the PHP type system",
            "homepage": "https://github.com/sebastianbergmann/type",
            "support": {
                "issues": "https://github.com/sebastianbergmann/type/issues",
                "source": "https://github.com/sebastianbergmann/type/tree/4.0.0"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-03T07:10:45+00:00"
        },
        {
            "name": "sebastian/version",
            "version": "4.0.1",
            "source": {
                "type": "git",
                "url": "https://github.com/sebastianbergmann/version.git",
                "reference": "c51fa83a5d8f43f1402e3f32a005e6262244ef17"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/sebastianbergmann/version/zipball/c51fa83a5d8f43f1402e3f32a005e6262244ef17",
                "reference": "c51fa83a5d8f43f1402e3f32a005e6262244ef17",
                "shasum": ""
            },
            "require": {
                "php": ">=8.1"
            },
            "type": "library",
            "extra": {
                "branch-alias": {
                    "dev-main": "4.0-dev"
                }
            },
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Sebastian Bergmann",
                    "email": "sebastian@phpunit.de",
                    "role": "lead"
                }
            ],
            "description": "Library that helps with managing the version number of Git-hosted PHP projects",
            "homepage": "https://github.com/sebastianbergmann/version",
            "support": {
                "issues": "https://github.com/sebastianbergmann/version/issues",
                "source": "https://github.com/sebastianbergmann/version/tree/4.0.1"
            },
            "funding": [
                {
                    "url": "https://github.com/sebastianbergmann",
                    "type": "github"
                }
            ],
            "time": "2023-02-07T11:34:05+00:00"
        },
        {
            "name": "symfony/config",
            "version": "v7.4.7",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/config.git",
                "reference": "6c17162555bfb58957a55bb0e43e00035b6ae3d5"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/config/zipball/6c17162555bfb58957a55bb0e43e00035b6ae3d5",
                "reference": "6c17162555bfb58957a55bb0e43e00035b6ae3d5",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/deprecation-contracts": "^2.5|^3",
                "symfony/filesystem": "^7.1|^8.0",
                "symfony/polyfill-ctype": "~1.8"
            },
            "conflict": {
                "symfony/finder": "<6.4",
                "symfony/service-contracts": "<2.5"
            },
            "require-dev": {
                "symfony/event-dispatcher": "^6.4|^7.0|^8.0",
                "symfony/finder": "^6.4|^7.0|^8.0",
                "symfony/messenger": "^6.4|^7.0|^8.0",
                "symfony/service-contracts": "^2.5|^3",
                "symfony/yaml": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Config\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Helps you find, load, combine, autofill and validate configuration values of any kind",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/config/tree/v7.4.7"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-03-06T10:41:14+00:00"
        },
        {
            "name": "symfony/dependency-injection",
            "version": "v7.4.7",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/dependency-injection.git",
                "reference": "0f651e58f4917fb0e2cd261ccbfe3d71e6e0f5db"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/dependency-injection/zipball/0f651e58f4917fb0e2cd261ccbfe3d71e6e0f5db",
                "reference": "0f651e58f4917fb0e2cd261ccbfe3d71e6e0f5db",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "psr/container": "^1.1|^2.0",
                "symfony/deprecation-contracts": "^2.5|^3",
                "symfony/service-contracts": "^3.6",
                "symfony/var-exporter": "^6.4.20|^7.2.5|^8.0"
            },
            "conflict": {
                "ext-psr": "<1.1|>=2",
                "symfony/config": "<6.4",
                "symfony/finder": "<6.4",
                "symfony/yaml": "<6.4"
            },
            "provide": {
                "psr/container-implementation": "1.1|2.0",
                "symfony/service-implementation": "1.1|2.0|3.0"
            },
            "require-dev": {
                "symfony/config": "^6.4|^7.0|^8.0",
                "symfony/expression-language": "^6.4|^7.0|^8.0",
                "symfony/yaml": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\DependencyInjection\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Allows you to standardize and centralize the way objects are constructed in your application",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/dependency-injection/tree/v7.4.7"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-03-03T07:48:48+00:00"
        },
        {
            "name": "symfony/var-exporter",
            "version": "v7.4.0",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/var-exporter.git",
                "reference": "03a60f169c79a28513a78c967316fbc8bf17816f"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/var-exporter/zipball/03a60f169c79a28513a78c967316fbc8bf17816f",
                "reference": "03a60f169c79a28513a78c967316fbc8bf17816f",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/deprecation-contracts": "^2.5|^3"
            },
            "require-dev": {
                "symfony/property-access": "^6.4|^7.0|^8.0",
                "symfony/serializer": "^6.4|^7.0|^8.0",
                "symfony/var-dumper": "^6.4|^7.0|^8.0"
            },
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\VarExporter\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Nicolas Grekas",
                    "email": "p@tchwork.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Allows exporting any serializable PHP data structure to plain PHP code",
            "homepage": "https://symfony.com",
            "keywords": [
                "clone",
                "construct",
                "export",
                "hydrate",
                "instantiate",
                "lazy-loading",
                "proxy",
                "serialize"
            ],
            "support": {
                "source": "https://github.com/symfony/var-exporter/tree/v7.4.0"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2025-09-11T10:15:23+00:00"
        },
        {
            "name": "symfony/yaml",
            "version": "v7.4.6",
            "source": {
                "type": "git",
                "url": "https://github.com/symfony/yaml.git",
                "reference": "58751048de17bae71c5aa0d13cb19d79bca26391"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/symfony/yaml/zipball/58751048de17bae71c5aa0d13cb19d79bca26391",
                "reference": "58751048de17bae71c5aa0d13cb19d79bca26391",
                "shasum": ""
            },
            "require": {
                "php": ">=8.2",
                "symfony/deprecation-contracts": "^2.5|^3",
                "symfony/polyfill-ctype": "^1.8"
            },
            "conflict": {
                "symfony/console": "<6.4"
            },
            "require-dev": {
                "symfony/console": "^6.4|^7.0|^8.0"
            },
            "bin": [
                "Resources/bin/yaml-lint"
            ],
            "type": "library",
            "autoload": {
                "psr-4": {
                    "Symfony\\Component\\Yaml\\": ""
                },
                "exclude-from-classmap": [
                    "/Tests/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "MIT"
            ],
            "authors": [
                {
                    "name": "Fabien Potencier",
                    "email": "fabien@symfony.com"
                },
                {
                    "name": "Symfony Community",
                    "homepage": "https://symfony.com/contributors"
                }
            ],
            "description": "Loads and dumps YAML files",
            "homepage": "https://symfony.com",
            "support": {
                "source": "https://github.com/symfony/yaml/tree/v7.4.6"
            },
            "funding": [
                {
                    "url": "https://symfony.com/sponsor",
                    "type": "custom"
                },
                {
                    "url": "https://github.com/fabpot",
                    "type": "github"
                },
                {
                    "url": "https://github.com/nicolas-grekas",
                    "type": "github"
                },
                {
                    "url": "https://tidelift.com/funding/github/packagist/symfony/symfony",
                    "type": "tidelift"
                }
            ],
            "time": "2026-02-09T09:33:46+00:00"
        },
        {
            "name": "theseer/tokenizer",
            "version": "1.3.1",
            "source": {
                "type": "git",
                "url": "https://github.com/theseer/tokenizer.git",
                "reference": "b7489ce515e168639d17feec34b8847c326b0b3c"
            },
            "dist": {
                "type": "zip",
                "url": "https://api.github.com/repos/theseer/tokenizer/zipball/b7489ce515e168639d17feec34b8847c326b0b3c",
                "reference": "b7489ce515e168639d17feec34b8847c326b0b3c",
                "shasum": ""
            },
            "require": {
                "ext-dom": "*",
                "ext-tokenizer": "*",
                "ext-xmlwriter": "*",
                "php": "^7.2 || ^8.0"
            },
            "type": "library",
            "autoload": {
                "classmap": [
                    "src/"
                ]
            },
            "notification-url": "https://packagist.org/downloads/",
            "license": [
                "BSD-3-Clause"
            ],
            "authors": [
                {
                    "name": "Arne Blankerts",
                    "email": "arne@blankerts.de",
                    "role": "Developer"
                }
            ],
            "description": "A small library for converting tokenized PHP source code into XML and potentially other formats",
            "support": {
                "issues": "https://github.com/theseer/tokenizer/issues",
                "source": "https://github.com/theseer/tokenizer/tree/1.3.1"
            },
            "funding": [
                {
                    "url": "https://github.com/theseer",
                    "type": "github"
                }
            ],
            "time": "2025-11-17T20:03:58+00:00"
        }
    ],
    "aliases": [],
    "minimum-stability": "stable",
    "stability-flags": [],
    "prefer-stable": false,
    "prefer-lowest": false,
    "platform": {
        "php": "^7.4 || ^8.0",
        "ext-filter": "*",
        "ext-json": "*",
        "ext-tokenizer": "*"
    },
    "platform-dev": [],
    "plugin-api-version": "2.2.0"
}
EOF_e8434e76373c
composer install
EOF_6947eff5282d


WORKDIR /testbed
