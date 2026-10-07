#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  echo "Usage: bash tool/release/prepare_portrai_release.sh" >&2
  exit 1
fi

cd "$(git rev-parse --show-toplevel)"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Commit or stash all changes before preparing a release." >&2
  exit 1
fi

git fetch origin --tags
git switch develop
git pull --ff-only origin develop

pubspec="app/portrai/pubspec.yaml"
version_line=$(awk '/^version:/' "$pubspec")
if [[ ! "$version_line" =~ ^version:[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$ ]]; then
  echo "Expected a single version: <major>.<minor>.<patch>+<build> in $pubspec." >&2
  exit 1
fi
version="${BASH_REMATCH[1]}"
current_build="${BASH_REMATCH[2]}"
tags=$(git tag --list)

# Android build numbers must increase across both review and production releases.
next_build=$(printf '%s\n' "$tags" | awk -v current="$current_build" '
  BEGIN { maximum = current + 0 }
  /^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+-(prod|review)$/ {
    split($0, parts, /[+-]/)
    if (parts[2] + 0 > maximum) maximum = parts[2] + 0
  }
  END {
    if (maximum >= 2100000000) {
      print "Cannot increment beyond the Android versionCode limit." > "/dev/stderr"
      exit 1
    }
    printf "%.0f\n", maximum + 1
  }
')

echo "Proposed production tag: $version+$next_build-prod"
echo "CI injects the version and build number from the tag."
echo "No files were modified and no commit, tag, or push was performed."
