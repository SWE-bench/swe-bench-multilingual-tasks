# We use a modern version of ubuntu as the base image because old node images
# can cause problems with agent installations. For eg. old GLIBC versions.
_DOCKERFILE_BASE_JS = r"""
FROM --platform=linux/amd64 ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && apt install -y \
    wget \
    curl \
    git \
    build-essential \
    jq \
    gnupg \
    ca-certificates \
    apt-transport-https

# Install node
RUN bash -c "set -eo pipefail && curl -fsSL https://deb.nodesource.com/setup_{node_version}.x | bash -"
RUN apt-get update && apt-get install -y nodejs
RUN node -v && npm -v

# Install pnpm
RUN npm install --global corepack@0.32.0
RUN corepack enable pnpm

# Install Chrome for browser testing
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Set up Chrome environment variables
ENV CHROME_BIN /usr/bin/google-chrome
ENV CHROME_PATH /usr/bin/google-chrome

RUN adduser --disabled-password --gecos 'dog' nonroot
"""


JEST_JSON_JQ_TRANSFORM = """jq -r '.testResults[].assertionResults[] | "[" + (.status | ascii_upcase) + "] " + ((.ancestorTitles | join(" > ")) + (if .ancestorTitles | length > 0 then " > " else "" end) + .title)'"""

SPECS_BABEL = {
    "14532": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ["yarn jest babel-generator --verbose"],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "13928": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ['yarn jest babel-parser -t "arrow" --verbose'],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "15649": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ["yarn jest packages/babel-traverse/test/scope.js --verbose"],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "15445": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            'yarn jest packages/babel-generator/test/index.js -t "generation " --verbose'
        ],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
    "16130": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": ["yarn jest babel-helpers --verbose"],
        "install": ["make bootstrap"],
        "build": ["make build"],
    },
}

SPECS_VUEJS = {
    "11899": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            "pnpm run test packages/compiler-sfc/__tests__/compileStyle.spec.ts --no-watch --reporter=verbose"
        ],
        "install": ["pnpm i"],
        "build": ["pnpm run build compiler-sfc"],
    },
    "11870": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            "pnpm run test packages/runtime-core/__tests__/helpers/renderList.spec.ts --no-watch --reporter=verbose"
        ],
        "install": ["pnpm i"],
    },
    "11739": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            'pnpm run test packages/runtime-core/__tests__/hydration.spec.ts --no-watch --reporter=verbose -t "mismatch handling"'
        ],
        "install": ["pnpm i"],
    },
    "11915": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            'pnpm run test packages/compiler-core/__tests__/parse.spec.ts --no-watch --reporter=verbose -t "Element"'
        ],
        "install": ["pnpm i"],
    },
    "11589": {
        "docker_specs": {"node_version": "20"},
        "test_cmd": [
            "pnpm run test packages/runtime-core/__tests__/apiWatch.spec.ts --no-watch --reporter=verbose"
        ],
        "install": ["pnpm i"],
    },
}

SPECS_DOCUSAURUS = {
    "10309": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-plugin-content-docs/src/client/__tests__/docsClientUtils.test.ts --verbose"
        ],
    },
    "10130": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus/src/server/__tests__/brokenLinks.test.ts --verbose"
        ],
    },
    "9897": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-utils/src/__tests__/markdownUtils.test.ts --verbose"
        ],
    },
    "9183": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-theme-classic/src/__tests__/options.test.ts --verbose"
        ],
    },
    "8927": {
        "docker_specs": {"node_version": "20"},
        "install": ["yarn install"],
        "test_cmd": [
            "yarn test packages/docusaurus-utils/src/__tests__/markdownLinks.test.ts --verbose"
        ],
    },
}

SPECS_IMMUTABLEJS = {
    "2006": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "build": ["npm run build"],
        "test_cmd": ["npx jest __tests__/Range.ts --verbose"],
    },
    "2005": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "build": ["npm run build"],
        "test_cmd": [
            f"npx jest __tests__/OrderedMap.ts __tests__/OrderedSet.ts --silent --json | {JEST_JSON_JQ_TRANSFORM}"
        ],
    },
}

SPECS_THREEJS = {
    "27395": {
        "docker_specs": {"node_version": "20"},
        # --ignore-scripts is used to avoid downloading chrome for puppeteer
        "install": ["npm install --ignore-scripts"],
        "test_cmd": ["npx qunit test/unit/src/math/Sphere.tests.js"],
    },
    "26589": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install --ignore-scripts"],
        "test_cmd": [
            "npx qunit test/unit/src/objects/Line.tests.js test/unit/src/objects/Mesh.tests.js test/unit/src/objects/Points.tests.js"
        ],
    },
    "25687": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install --ignore-scripts"],
        "test_cmd": [
            'npx qunit test/unit/src/core/Object3D.tests.js -f "/json|clone|copy/i"'
        ],
    },
}

SPECS_PREACT = {
    "4152": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/components.test.js"'
        ],
    },
    "4316": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/events.test.js"'
        ],
    },
    "4245": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useId.test.js"'
        ],
    },
    "4182": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/errorBoundary.test.js"'
        ],
    },
    "4436": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/refs.test.js"'
        ],
    },
    "3763": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/lifecycles/componentDidMount.test.js"'
        ],
    },
    "3739": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useState.test.js"',
        ],
    },
    "3689": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/errorBoundary.test.js"',
        ],
    },
    "3567": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useEffect.test.js"',
        ],
    },
    "3562": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="compat/test/browser/render.test.js"',
        ],
    },
    "3454": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/svg.test.js"',
        ],
    },
    "3345": {
        "docker_specs": {"node_version": "18"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="hooks/test/browser/useEffect.test.js"',
        ],
    },
    "3062": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
    "3010": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
    "2927": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install", "git checkout -- mangle.json"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
    "2896": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="compat/test/browser/memo.test.js"',
        ],
    },
    "2757": {
        "docker_specs": {"node_version": "16"},
        "install": ["npm install"],
        "test_cmd": [
            'COVERAGE=false BABEL_NO_MODULES=true npx karma start karma.conf.js --single-run --grep="test/browser/render.test.js"',
        ],
    },
}

SPECS_AXIOS = {
    "5892": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha test/unit/adapters/http.js -R tap -g 'compression'"],
    },
    "5316": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        # Patch involves adding a new dependency, so we need to re-install
        "build": ["npm install"],
        "test_cmd": ["npx mocha test/unit/adapters/http.js -R tap -g 'FormData'"],
    },
    "4738": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        # Tests get stuck for some reason, so we run them with a timeout
        "test_cmd": [
            "timeout 10s npx mocha -R tap test/unit/adapters/http.js -g 'timeout'"
        ],
    },
    "4731": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha -R tap test/unit/adapters/http.js -g 'body length'"],
    },
    "6539": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha -R tap test/unit/regression/SNYK-JS-AXIOS-7361793.js"],
    },
    "5085": {
        "docker_specs": {"node_version": "20"},
        "install": ["npm install"],
        "test_cmd": ["npx mocha -R tap test/unit/regression/bugs.js"],
    },
}


MAP_REPO_VERSION_TO_SPECS_JS = {
    "babel/babel": SPECS_BABEL,
    "vuejs/core": SPECS_VUEJS,
    "facebook/docusaurus": SPECS_DOCUSAURUS,
    "immutable-js/immutable-js": SPECS_IMMUTABLEJS,
    "mrdoob/three.js": SPECS_THREEJS,
    "preactjs/preact": SPECS_PREACT,
    "axios/axios": SPECS_AXIOS,
}

# Constants - Repository Specific Installation Instructions
MAP_REPO_TO_INSTALL_JS = {}
