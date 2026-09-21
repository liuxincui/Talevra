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

VERSION="$(awk '/^version:/ { print $2; exit }' "${PROJECT_DIR}/pubspec.yaml")"
[[ "${VERSION}" == *+* ]] || fail "Invalid version in pubspec.yaml: ${VERSION}"
VERSION_NAME="${VERSION%%+*}"
VERSION_CODE="${VERSION##*+}"

OUTPUT_DIR="${PROJECT_DIR}/release/${FLAVOR}/${VERSION_NAME}"
SYMBOL_DIR="${OUTPUT_DIR}/flutter-symbols"
APK_SOURCE="${PROJECT_DIR}/build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
APK_OUTPUT="${OUTPUT_DIR}/Talevra-${PACKAGE_NAME}-v${VERSION_NAME}-${VERSION_CODE}.apk"
R8_SOURCE="${PROJECT_DIR}/build/app/outputs/mapping/brand_usRelease/mapping.txt"

mkdir -p "${SYMBOL_DIR}"
cd "${PROJECT_DIR}"

echo "Building ${PACKAGE_NAME} ${VERSION_NAME} (${VERSION_CODE}) for ${BUILD_ENV}..."
flutter pub get
flutter analyze
flutter build apk \
  --flavor "${FLAVOR}" \
  --release \
  -t "${ENTRYPOINT}" \
  --dart-define="ENV=${BUILD_ENV}" \
  --obfuscate \
  --split-debug-info="${SYMBOL_DIR}"

require_file "${APK_SOURCE}"
cp "${APK_SOURCE}" "${APK_OUTPUT}"

if [[ -f "${R8_SOURCE}" ]]; then
  cp "${R8_SOURCE}" "${OUTPUT_DIR}/r8-mapping.txt"
else
  echo "WARNING: R8 mapping was not found at ${R8_SOURCE}" >&2
fi

echo
echo "Release build complete:"
echo "  APK: ${APK_OUTPUT}"
echo "  Flutter symbols: ${SYMBOL_DIR}"
[[ -f "${OUTPUT_DIR}/r8-mapping.txt" ]] && \
  echo "  R8 mapping: ${OUTPUT_DIR}/r8-mapping.txt"

if command -v shasum >/dev/null 2>&1; then
  echo "  SHA-256: $(shasum -a 256 "${APK_OUTPUT}" | awk '{print $1}')"
elif command -v sha256sum >/dev/null 2>&1; then
  echo "  SHA-256: $(sha256sum "${APK_OUTPUT}" | awk '{print $1}')"
fi
