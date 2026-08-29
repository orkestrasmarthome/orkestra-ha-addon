#!/usr/bin/env bash
# Keep orkestra_staging/config.yaml version aligned with orkestra/config.yaml.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

read_yaml_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^${field}:[[:space:]]*[\"']*\\([^\"']*\\)[\"']*/\\1/p" "${file}" | head -1
}

PROD_CONFIG="orkestra/config.yaml"
STAGING_CONFIG="orkestra_staging/config.yaml"

prod_version="$(read_yaml_field "${PROD_CONFIG}" version)"
staging_version="$(read_yaml_field "${STAGING_CONFIG}" version)"

if [[ -z "${prod_version}" ]]; then
  echo "::error::Could not read version from ${PROD_CONFIG}"
  exit 1
fi

if [[ "${prod_version}" == "${staging_version}" ]]; then
  echo "Add-on versions already aligned at ${prod_version}"
  exit 0
fi

sed -i "s/^version:[[:space:]]*[\"']*${staging_version}[\"']*/version: \"${prod_version}\"/" "${STAGING_CONFIG}"
echo "Synced ${STAGING_CONFIG} version ${staging_version} -> ${prod_version}"
