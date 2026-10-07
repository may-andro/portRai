#!/usr/bin/env bash
set -euo pipefail

script="$(cd "$(dirname "$0")" && pwd)/prepare_portrai_release.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

git init --bare --quiet "$fixture/origin.git"
git init --quiet -b develop "$fixture/work"
cd "$fixture/work"
git config user.email "release-test@example.com"
git config user.name "Release Test"
mkdir -p app/portrai
printf 'name: portrai\nversion: 1.0.0+1\n' > app/portrai/pubspec.yaml
git add .
git commit --quiet -m "Initial app"
git remote add origin "$fixture/origin.git"
git push --quiet -u origin develop
git clone --quiet --branch develop "$fixture/origin.git" "$fixture/remote"
git -C "$fixture/remote" tag 1.0.0+9-prod
git -C "$fixture/remote" tag 1.0.0+10-review
git -C "$fixture/remote" tag 1.0.0+99-prod-storybook
git -C "$fixture/remote" tag legal-100
git -C "$fixture/remote" push --quiet origin --tags
git switch --quiet -c fix/test
head_before=$(git rev-parse HEAD)

output=$(bash "$script")
[[ "$(git branch --show-current)" == develop ]]
grep -qx 'version: 1.0.0+1' app/portrai/pubspec.yaml
[[ "$output" == *"Proposed production tag: 1.0.0+11-prod"* ]]
[[ "$(git rev-parse HEAD)" == "$head_before" ]]
[[ -z "$(git tag --list '1.0.0+11-prod')" ]]
[[ -z "$(git status --porcelain)" ]]
echo "should fetch remote app tags and increment numerically when preparing a release"

bash "$script" > "$fixture/output"
grep -q "Proposed production tag: 1.0.0+11-prod" "$fixture/output"
[[ -z "$(git status --porcelain)" ]]
echo "should propose the same tag when no release has been tagged"

printf 'name: portrai\nversion: 1.0.0+20\n' > app/portrai/pubspec.yaml
if bash "$script" > "$fixture/output" 2>&1; then
  echo "Expected a dirty working tree to be rejected." >&2
  exit 1
fi
grep -q "Commit or stash" "$fixture/output"
grep -qx 'version: 1.0.0+20' app/portrai/pubspec.yaml
echo "should refuse changes when the working tree is dirty"

git add .
git commit --quiet -m "Higher local build"
git push --quiet origin develop
bash "$script" > "$fixture/output"
grep -qx 'version: 1.0.0+20' app/portrai/pubspec.yaml
grep -q "Proposed production tag: 1.0.0+21-prod" "$fixture/output"
[[ -z "$(git status --porcelain)" ]]
echo "should use the pubspec build as a baseline when it is higher than every tag"

git -C "$fixture/remote" pull --quiet --ff-only origin develop
git -C "$fixture/remote" config user.email "release-test@example.com"
git -C "$fixture/remote" config user.name "Release Test"
printf 'name: portrai\nversion: 1.2.0+20\n' > "$fixture/remote/app/portrai/pubspec.yaml"
git -C "$fixture/remote" add .
git -C "$fixture/remote" commit --quiet -m "New app version"
git -C "$fixture/remote" push --quiet origin develop
bash "$script" > "$fixture/output"
grep -qx 'version: 1.2.0+20' app/portrai/pubspec.yaml
grep -q "Proposed production tag: 1.2.0+21-prod" "$fixture/output"
[[ -z "$(git status --porcelain)" ]]
echo "should pull develop and preserve its semantic version when remote changes exist"

git -C "$fixture/remote" tag 1.2.0+2100000000-prod
git -C "$fixture/remote" push --quiet origin 1.2.0+2100000000-prod
if bash "$script" > "$fixture/output" 2>&1; then
  echo "Expected the Android build number limit to be enforced." >&2
  exit 1
fi
grep -q "Android versionCode limit" "$fixture/output"
grep -qx 'version: 1.2.0+20' app/portrai/pubspec.yaml
echo "should leave pubspec unchanged when incrementing would exceed the Android limit"
