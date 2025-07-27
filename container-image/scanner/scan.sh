#!/usr/bin/env bash

set -euo pipefail

err_echo() {
    printf "\033[31m%s\033[0m\n" "$1" >&2
}

note_echo() {
    printf "\033[35m%s\033[0m\n" "$1"
}

if [[ -z "${RENOVATE_TOKEN:-}" ]]; then
	err_echo "ERROR: Missing environment variable RENOVATE_TOKEN"
	exit 1
fi

# Glob on spaces intentionally
repo_slugs=$@

if [[ $# -eq 0 ]]; then
    echo -n "Enter space-separated repo slugs (i.e. oapi-codegen/oapi-codegen): "

    # make it explicit that we need to cancel the process if interrupted - sometimes the `^C` or similar doesn't get correctly picked up when using this setup
    trap 'echo; exit 130' INT

    read -r repo_slugs

    # then un-set the trap
    trap - INT
fi

if [[ -z "$repo_slugs" ]]; then
    err_echo "No repo slugs were provided"
    exit 1
fi

note_echo "Processing $repo_slugs"

# Glob on spaces intentionally
env LOG_LEVEL=warn OUT_DIR=out/renovate-graph renovate-graph $repo_slugs
# some users may want to use GitLab, so we shouldn't run `dependabot-graph` against them
if [[ -z "${RENOVATE_PLATFORM:-}" || "github" == "${RENOVATE_PLATFORM:-}" ]]; then
    # Glob on spaces intentionally
    env GITHUB_TOKEN="$RENOVATE_TOKEN" dependabot-graph $repo_slugs
fi

note_echo "Finished processing, to import, run:"

echo '# I.e. if you have `dmd.db`'

if [[ -z "${RENOVATE_PLATFORM:-}" || "github" == "${RENOVATE_PLATFORM:-}" ]]; then
    # Glob intentionally
    echo "cd $EXTERNAL_PWD && dmd import dependabot --db dmd.db" out/*.json
fi
# Glob intentionally
echo "cd $EXTERNAL_PWD && dmd import renovate --db dmd.db" out/renovate-graph/*.json
