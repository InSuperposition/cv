#!/usr/bin/env bash
# Sign a pushed image keyless, by digest, with the workflow's OIDC identity.
# Usage: sign-image.sh <image-repository> <digest>
set -euo pipefail

repository="$(tr "[:upper:]" "[:lower:]" <<<"${1:?image repository}")"
digest="${2:?image digest}"

[[ "$digest" =~ ^sha256:[a-f0-9]{64}$ ]] || {
  echo "not a sha256 digest: $digest" >&2
  exit 1
}

cosign sign --yes "${repository}@${digest}"
