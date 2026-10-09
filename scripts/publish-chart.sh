#!/usr/bin/env bash
# Package the chart at a version, push it to an OCI registry and sign the
# pushed artifact keyless, by digest.
# Usage: publish-chart.sh <version> <registry-repository>
# Example: publish-chart.sh 1.2.3 ghcr.io/owner/charts
set -euo pipefail

version="${1:?chart version}"
registry="$(tr "[:upper:]" "[:lower:]" <<<"${2:?registry repository}")"
chart_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/../chart" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

helm package "$chart_directory" --version "$version" --app-version "$version" --destination "$work" >/dev/null

push_output="$(helm push "$work/cv-${version}.tgz" "oci://${registry}" 2>&1)"
echo "$push_output"

digest="$(sed -n 's/^Digest: \(sha256:[a-f0-9]\{64\}\)$/\1/p' <<<"$push_output")"
[[ -n "$digest" ]] || {
  echo "helm push printed no digest" >&2
  exit 1
}

cosign sign --yes "${registry}/cv@${digest}"
echo "chart-digest=${digest}"
