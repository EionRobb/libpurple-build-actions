#!/usr/bin/env bash
set -euo pipefail
: "${SDK_URL:?sdk-url is required}"
: "${SDK_SHA256:?sdk-sha256 is required}"
: "${OSXCROSS_COMMIT:?osxcross-commit is required}"
if [[ ! "$SDK_URL" == https://* || ! "$SDK_SHA256" =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "::error::Provide an HTTPS SDK URL and a 64-character SHA-256 checksum" >&2
  exit 1
fi
source_dir="$RUNNER_TEMP/osxcross-src"
git clone -q https://github.com/tpoechtrager/osxcross.git "$source_dir"
git -C "$source_dir" checkout -q "$OSXCROSS_COMMIT"
mkdir -p "$source_dir/tarballs"
sdk_name="$(basename "${SDK_URL%%\?*}")"
if [[ ! "$sdk_name" =~ ^MacOSX[0-9.]+\.sdk\.tar\.(xz|bz2)$ ]]; then
  echo "::error::SDK URL must end in MacOSX<version>.sdk.tar.xz (or .tar.bz2)" >&2
  exit 1
fi
curl -fLsS --retry 3 "$SDK_URL" -o "$source_dir/tarballs/$sdk_name"
echo "$SDK_SHA256  $source_dir/tarballs/$sdk_name" | sha256sum -c -
sudo mkdir -p /opt/osxcross
sudo chown "$USER" /opt/osxcross
cd "$source_dir"
UNATTENDED=1 BUILD_FLAVOR=stable TARGET_DIR=/opt/osxcross ENABLE_ARCHS="x86_64 arm64" ./build.sh
