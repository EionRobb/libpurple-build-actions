#!/usr/bin/env bash
set -euo pipefail
: "${PIDGIN_VERSION:=2.14.1}"
: "${SDK_RELEASE:=win32-sdk-v1}"

asset="pidgin-win32-sdk-${PIDGIN_VERSION}.tar.gz"
url="https://github.com/EionRobb/libpurple-build-actions/releases/download/${SDK_RELEASE}/${asset}"
tmpdir="$(mktemp -d)"
if curl -fsSL --retry 2 "$url" -o "$tmpdir/$asset" &&
   curl -fsSL --retry 2 "$url.sha256" -o "$tmpdir/$asset.sha256" &&
   (cd "$tmpdir" && sha256sum -c "$asset.sha256"); then
  tar -xzf "$tmpdir/$asset"
else
  echo "::notice::Verified shared SDK archive unavailable; preparing from upstream sources"
  bash "$GITHUB_ACTION_PATH/scripts/build-sdk.sh"
fi
test -f pidgin/libpurple/libpurple.dll
test -d win32-dev/glib-2.28.8/include
