#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

FLAVOR="brand_us"
ENTRYPOINT="lib/main_brand_us.dart"
PACKAGE_NAME="com.talevra.story"
BUILD_ENV="${TALEVRA_ENV:-prod}"
LOCAL_PROPERTIES="${PROJECT_DIR}/android/local.properties"
KEY_PROPERTIES="${PROJECT_DIR}/android/key.properties"
LICENSE_FILE="${PROJECT_DIR}/android/app/src/main/assets/vod_player.lic"
PUBSPEC_FILE="${PROJECT_DIR}/pubspec.yaml"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing required file: $1"
}

property_value() {
  awk -F= -v key="$2" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$1"
}

set_pubspec_version() {
  local version="$1"
  local temporary_file
  temporary_file="$(mktemp)"
  awk -v version="${version}" '
    /^version:/ && !updated { print "version: " version; updated = 1; next }
    { print }
    END { if (!updated) exit 1 }
  ' "${PUBSPEC_FILE}" > "${temporary_file}"
  cp "${temporary_file}" "${PUBSPEC_FILE}"
  rm -f "${temporary_file}"
}

command -v flutter >/dev/null 2>&1 || fail "flutter is not available in PATH"

if [[ "$(uname -s)" == "Darwin" ]] && [[ -x /usr/libexec/java_home ]]; then
  JAVA_17_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null || true)"
  if [[ -n "${JAVA_17_HOME}" ]]; then
    export JAVA_HOME="${JAVA_17_HOME}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
  fi
fi

command -v java >/dev/null 2>&1 || fail "java is not available in PATH"
JAVA_VERSION="$(java -version 2>&1 | awk 'NR == 1 { print }' | sed -E 's/.*version "([^"]+)".*/\1/')"
JAVA_MAJOR="${JAVA_VERSION%%.*}"
if [[ "${JAVA_MAJOR}" == "1" ]]; then
  JAVA_MAJOR="$(printf '%s' "${JAVA_VERSION}" | cut -d. -f2)"
fi
[[ "${JAVA_MAJOR}" =~ ^[0-9]+$ ]] && (( JAVA_MAJOR >= 17 )) || \
  fail "Java 17 or later is required (found: ${JAVA_VERSION})"

require_file "${PROJECT_DIR}/${ENTRYPOINT}"
require_file "${PUBSPEC_FILE}"
require_file "${LOCAL_PROPERTIES}"
require_file "${KEY_PROPERTIES}"
require_file "${LICENSE_FILE}"

for key in pssdk.appId pssdk.vodAppId pssdk.securityKey pssdk.licenseAssetPath; do
  [[ -n "$(property_value "${LOCAL_PROPERTIES}" "$key")" ]] || \
    fail "Missing $key in android/local.properties"
done

KEYSTORE_NAME="$(property_value "${KEY_PROPERTIES}" storeFile)"
[[ -n "${KEYSTORE_NAME}" ]] || fail "Missing storeFile in android/key.properties"
require_file "${PROJECT_DIR}/android/app/${KEYSTORE_NAME}"

CURRENT_VERSION="$(awk '/^version:/ { print $2; exit }' "${PUBSPEC_FILE}")"
[[ "${CURRENT_VERSION}" == *+* ]] || \
  fail "Invalid version in pubspec.yaml: ${CURRENT_VERSION}"
CURRENT_VERSION_NAME="${CURRENT_VERSION%%+*}"
CURRENT_VERSION_CODE="${CURRENT_VERSION##*+}"

[[ "${CURRENT_VERSION_NAME}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || \
  fail "Version name must use major.minor.patch format: ${CURRENT_VERSION_NAME}"
CURRENT_MAJOR="${BASH_REMATCH[1]}"
CURRENT_MINOR="${BASH_REMATCH[2]}"
CURRENT_PATCH="${BASH_REMATCH[3]}"
[[ "${CURRENT_VERSION_CODE}" =~ ^[0-9]+$ ]] || \
  fail "Version code must be numeric: ${CURRENT_VERSION_CODE}"

if [[ -n "${TALEVRA_VERSION_NAME:-}" ]]; then
  [[ "${TALEVRA_VERSION_NAME}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
    fail "TALEVRA_VERSION_NAME must use major.minor.patch format"
  VERSION_NAME="${TALEVRA_VERSION_NAME}"
else
  VERSION_NAME="${CURRENT_MAJOR}.${CURRENT_MINOR}.$((10#${CURRENT_PATCH} + 1))"
fi
VERSION_CODE="$((10#${CURRENT_VERSION_CODE} + 1))"
VERSION="${VERSION_NAME}+${VERSION_CODE}"

VERSION_CHANGED=false
restore_version_on_failure() {
  local status=$?
  if (( status != 0 )) && [[ "${VERSION_CHANGED}" == true ]]; then
    set_pubspec_version "${CURRENT_VERSION}"
    echo "Build failed; restored version ${CURRENT_VERSION}." >&2
  fi
  trap - EXIT
  exit "${status}"
}
trap restore_version_on_failure EXIT

set_pubspec_version "${VERSION}"
VERSION_CHANGED=true
echo "Version updated: ${CURRENT_VERSION} -> ${VERSION}"

OUTPUT_DIR="${PROJECT_DIR}/release/${FLAVOR}/${VERSION_NAME}"
SYMBOL_DIR="${OUTPUT_DIR}/flutter-symbols"
AAB_SOURCE="${PROJECT_DIR}/build/app/outputs/bundle/brand_usRelease/app-${FLAVOR}-release.aab"
AAB_OUTPUT="${OUTPUT_DIR}/Talevra-${PACKAGE_NAME}-v${VERSION_NAME}-${VERSION_CODE}.aab"
R8_SOURCE="${PROJECT_DIR}/build/app/outputs/mapping/brand_usRelease/mapping.txt"

mkdir -p "${SYMBOL_DIR}"
cd "${PROJECT_DIR}"

echo "Building AAB for ${PACKAGE_NAME} ${VERSION_NAME} (${VERSION_CODE}) in ${BUILD_ENV}..."
flutter pub get
flutter analyze
flutter build appbundle \
  --flavor "${FLAVOR}" \
  --release \
  -t "${ENTRYPOINT}" \
  --dart-define="ENV=${BUILD_ENV}" \
  --obfuscate \
  --split-debug-info="${SYMBOL_DIR}"

require_file "${AAB_SOURCE}"
cp "${AAB_SOURCE}" "${AAB_OUTPUT}"

if [[ -f "${R8_SOURCE}" ]]; then
  cp "${R8_SOURCE}" "${OUTPUT_DIR}/r8-mapping.txt"
else
  echo "WARNING: R8 mapping was not found at ${R8_SOURCE}" >&2
fi

echo
echo "AAB release build complete:"
echo "  AAB: ${AAB_OUTPUT}"
echo "  Flutter symbols: ${SYMBOL_DIR}"
[[ -f "${OUTPUT_DIR}/r8-mapping.txt" ]] && \
  echo "  R8 mapping: ${OUTPUT_DIR}/r8-mapping.txt"

if command -v shasum >/dev/null 2>&1; then
  echo "  SHA-256: $(shasum -a 256 "${AAB_OUTPUT}" | awk '{print $1}')"
elif command -v sha256sum >/dev/null 2>&1; then
  echo "  SHA-256: $(sha256sum "${AAB_OUTPUT}" | awk '{print $1}')"
fi

VERSION_CHANGED=false
trap - EXIT
