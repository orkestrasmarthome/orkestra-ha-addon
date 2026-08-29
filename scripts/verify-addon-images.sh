#!/usr/bin/env bash
# Verify published GHCR images exist for the add-on version in config.yaml.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

VERSION="${1:-}"
IMAGE_PREFIX="${IMAGE_PREFIX:-ghcr.io/orkestrasmarthome/orkestra-core}"
ARCHES="${ARCHES:-amd64 aarch64}"

if [[ -z "${VERSION}" ]]; then
  VERSION="$(sed -n 's/^version:[[:space:]]*["'\'']*\([^"'\'']*\)["'\'']*/\1/p' orkestra/config.yaml | head -1)"
fi

[[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "::error::Invalid version: ${VERSION:-<empty>}"
  exit 1
}

check_manifest() {
  local image="$1"
  local code

  code="$(curl -fsSL -o /dev/null -w '%{http_code}' \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "https://${image}/manifests/${VERSION}" || true)"

  if [[ "${code}" != "200" ]]; then
    echo "::error::Missing image manifest: ${image}:${VERSION} (HTTP ${code})"
    return 1
  fi

  echo "Found ${image}:${VERSION}"
}

missing=0
for arch in ${ARCHES}; do
  check_manifest "${IMAGE_PREFIX}-${arch}" || missing=1
done

if [[ "${missing}" -ne 0 ]]; then
  exit 1
fi

echo "All required GHCR images are available for version ${VERSION}"
