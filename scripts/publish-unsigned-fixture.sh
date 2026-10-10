#!/usr/bin/env bash
# Package the chart under the name cv-unsigned and push it to an OCI registry
# WITHOUT signing it. It exists so a consumer can test that it refuses a chart
# with no signature; never deploy it.
# Usage: publish-unsigned-fixture.sh <version> <registry-repository>
# Example: publish-unsigned-fixture.sh 0.0.1 ghcr.io/owner/charts
set -euo pipefail

version="${1:?chart version}"
registry="$(tr "[:upper:]" "[:lower:]" <<<"${2:?registry repository}")"
chart_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/../chart" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

cp -R "$chart_directory" "$work/cv-unsigned"
sed -i.bak 's/^name: cv$/name: cv-unsigned/' "$work/cv-unsigned/Chart.yaml"
rm "$work/cv-unsigned/Chart.yaml.bak"
mkdir "$work/out"

helm package "$work/cv-unsigned" --version "$version" --app-version "$version" --destination "$work/out" >/dev/null

push_output="$(helm push "$work/out/cv-unsigned-${version}.tgz" "oci://${registry}" 2>&1)"
echo "$push_output"

digest="$(sed -n 's/^Digest: \(sha256:[a-f0-9]\{64\}\)$/\1/p' <<<"$push_output")"
[[ -n "$digest" ]] || {
  echo "helm push printed no digest" >&2
  exit 1
}
echo "chart-digest=${digest}"
