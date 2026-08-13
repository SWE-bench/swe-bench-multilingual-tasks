# Changelog

- **[2026-08-13] Stop pinning laravel installs to a mis-captured composer fixture**: the
  captured `composer.json` required `orchestra/testbench-core ^10.x` while these commits
  want `^9.x`, so `composer install` could not resolve and the image failed to build.
  Dropped the fixtures and let the repo's own manifest resolve; also `git checkout -B master`
  (a `--single-branch` clone lands on laravel's current default, which composer uses to
  derive the root version) and `rm -f composer.lock`. 9 instances: `laravel__framework-51195`,
  `-51890`, `-52451`, `-52680`, `-52684`, `-52866`, `-53206`, `-53696`, `-53949`.
- **[2026-08-13] Pin composer's root version for one laravel instance**: composer infers
  `laravel/framework`'s own version from the checked-out branch, which now resolves to
  `13.x-dev` and conflicts with the locked `testbench-core` 10.2.1 (`<13.0.0`), so
  `composer install` refused the lock. Set `COMPOSER_ROOT_VERSION=12.9.9` and kept the
  fixture, which reproduces the previously passing image. `laravel__framework-53914`.
- **[2026-08-13] Remove future commits reliably when cloning**: same fix as the Verified
  repo — date-based tag pruning via a `for` loop (a `while read` loop's git calls ate the
  piped stdin), plus `git reflog expire` and `git gc --prune=now` so unreferenced future
  commits are physically gone, and a build-time assertion that no commit after
  `base_commit` remains. All instances.
- **[2026-08-13] Fall back to a full clone when a mapped branch is gone**: `git clone
  --branch X --single-branch` exits 128 once upstream deletes branch X, failing the build;
  retry without the branch pin. Any instance whose branch mapping goes stale.

## Known issues

- `apache__lucene-13170` is flaky and not chased.
