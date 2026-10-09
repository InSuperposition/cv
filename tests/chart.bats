#!/usr/bin/env bats

setup() {
  chart="$(cd "$BATS_TEST_DIRNAME/../chart" && pwd)"
  digest="sha256:$(printf 'a%.0s' {1..64})"
}

@test "the image is pinned by digest" {
  run helm template cv "$chart" --set image.digest="$digest"
  [ "$status" -eq 0 ]
  [[ "$output" == *"image: ghcr.io/insuperposition/cv@$digest"* ]]
}

@test "an install without a digest is refused by the schema" {
  run helm template cv "$chart"
  [ "$status" -ne 0 ]
  [[ "$output" == *image/digest* ]]
}

@test "a tag in place of a digest is refused by the schema" {
  run helm template cv "$chart" --set image.digest=v1.2.3
  [ "$status" -ne 0 ]
  [[ "$output" == *image/digest* ]]
}

@test "the pod has its own service account and no API token" {
  run helm template cv "$chart" --set image.digest="$digest"
  [ "$status" -eq 0 ]
  [ "$(grep -c 'automountServiceAccountToken: false' <<<"$output")" -eq 2 ]
  [[ "$output" == *"serviceAccountName: cv"* ]]
}

@test "the container runs non-root with a read-only root filesystem and no capabilities" {
  run helm template cv "$chart" --set image.digest="$digest"
  [[ "$output" == *"runAsNonRoot: true"* ]]
  [[ "$output" == *"readOnlyRootFilesystem: true"* ]]
  [[ "$output" == *"drop: [ALL]"* ]]
}
