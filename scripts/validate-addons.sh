#!/usr/bin/env bash
# Validate Orkestra Home Assistant add-on store manifests.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

ADDONS=(
  "orkestra:orkestra"
  "orkestra_staging:orkestra_staging"
)

fail() {
  echo "::error::${1}" >&2
  exit 1
}

read_yaml_field() {
  local file="$1"
  local field="$2"
  sed -n "s/^${field}:[[:space:]]*[\"']*\\([^\"']*\\)[\"']*/\\1/p" "${file}" | head -1
}

[[ -f repository.yaml ]] || fail "Missing repository.yaml at repository root"

for entry in "${ADDONS[@]}"; do
  folder="${entry%%:*}"
  expected_slug="${entry##*:}"
  config="${folder}/config.yaml"

  [[ -d "${folder}" ]] || fail "Missing add-on directory: ${folder}"
  [[ -f "${config}" ]] || fail "Missing manifest: ${config}"

  slug="$(read_yaml_field "${config}" slug)"
  version="$(read_yaml_field "${config}" version)"
  name="$(read_yaml_field "${config}" name)"
  image="$(read_yaml_field "${config}" image)"

  [[ "${slug}" == "${expected_slug}" ]] || fail "${config}: slug '${slug}' must match folder '${expected_slug}'"
  [[ "${slug}" == "${folder}" ]] || fail "${config}: folder '${folder}' must match slug '${slug}'"
  [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "${config}: invalid semver version '${version:-<empty>}'"
  [[ -n "${name}" ]] || fail "${config}: missing name"
  [[ -n "${image}" ]] || fail "${config}: missing prebuilt image reference"
  [[ "${image}" == *"{arch}"* ]] || fail "${config}: image must include {arch} placeholder"

  for asset in icon.png logo.jpeg; do
    [[ -f "${folder}/${asset}" ]] || fail "${config}: missing branding asset ${folder}/${asset}"
  done

  echo "Validated ${folder} (${name} v${version})"
done

prod_version="$(read_yaml_field orkestra/config.yaml version)"
staging_version="$(read_yaml_field orkestra_staging/config.yaml version)"

if [[ "${prod_version}" != "${staging_version}" ]]; then
  fail "Version mismatch: orkestra=${prod_version}, orkestra_staging=${staging_version}"
fi

echo "Add-on store validation passed (release version ${prod_version})"
