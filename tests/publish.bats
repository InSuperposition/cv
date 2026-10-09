#!/usr/bin/env bats

setup() {
  root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  stubs="$BATS_TEST_TMPDIR/bin"
  calls="$BATS_TEST_TMPDIR/calls"
  mkdir -p "$stubs"
  : >"$calls"
  export calls
  cat >"$stubs/helm" <<'STUB'
#!/usr/bin/env bash
echo "helm $*" >>"$calls"
case "$1" in
  package) touch "${@: -1}/cv-${3}.tgz" ;;
  push) printf 'Pushed: %s/cv:1.2.3\nDigest: sha256:%s\n' "${3#oci://}" "$(printf 'b%.0s' {1..64})" ;;
esac
STUB
  cat >"$stubs/cosign" <<'STUB'
#!/usr/bin/env bash
echo "cosign $*" >>"$calls"
STUB
  chmod +x "$stubs"/*
  PATH="$stubs:$PATH"
}

@test "the chart is packaged at the version, pushed, and signed by the digest the push printed" {
  run "$root/scripts/publish-chart.sh" 1.2.3 ghcr.io/owner/charts
  [ "$status" -eq 0 ]
  grep -q -- "helm package .* --version 1.2.3 --app-version 1.2.3" "$calls"
  grep -q "helm push .*cv-1.2.3.tgz oci://ghcr.io/owner/charts" "$calls"
  grep -q "cosign sign --yes ghcr.io/owner/charts/cv@sha256:$(printf 'b%.0s' {1..64})" "$calls"
}

@test "an owner with capitals is pushed under a lowercase name" {
  run "$root/scripts/publish-chart.sh" 1.2.3 ghcr.io/Some-Owner/charts
  [ "$status" -eq 0 ]
  grep -q "oci://ghcr.io/some-owner/charts" "$calls"
}

@test "a push that prints no digest fails without signing" {
  cat >"$stubs/helm" <<'STUB'
#!/usr/bin/env bash
echo "helm $*" >>"$calls"
STUB
  run "$root/scripts/publish-chart.sh" 1.2.3 ghcr.io/owner/charts
  [ "$status" -ne 0 ]
  run grep -q cosign "$calls"
  [ "$status" -ne 0 ]
}

@test "the image is signed by its digest under a lowercase name" {
  digest="sha256:$(printf 'c%.0s' {1..64})"
  run "$root/scripts/sign-image.sh" ghcr.io/Owner/Cv "$digest"
  [ "$status" -eq 0 ]
  grep -q "cosign sign --yes ghcr.io/owner/cv@$digest" "$calls"
}

@test "an image reference that is not a digest is refused without signing" {
  run "$root/scripts/sign-image.sh" ghcr.io/owner/cv v1.2.3
  [ "$status" -ne 0 ]
  run grep -q cosign "$calls"
  [ "$status" -ne 0 ]
}
