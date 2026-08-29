#!/usr/bin/env bash
# Package the add-on store layout for GitHub release artifacts.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

VERSION="$(sed -n 's/^version:[[:space:]]*["'\'']*\([^"'\'']*\)["'\'']*/\1/p' orkestra/config.yaml | head -1)"
OUTPUT_DIR="${1:-dist}"
ARCHIVE="${OUTPUT_DIR}/orkestra-addon-store-${VERSION}.tar.gz"

mkdir -p "${OUTPUT_DIR}"

tar -czf "${ARCHIVE}" \
  repository.yaml \
  orkestra/config.yaml \
  orkestra/README.md \
  orkestra/icon.png \
  orkestra/logo.jpeg

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "archive=${ARCHIVE}" >> "${GITHUB_OUTPUT}"
fi

echo "Packaged ${ARCHIVE}"
