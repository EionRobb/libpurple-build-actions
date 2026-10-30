#!/usr/bin/env bash
set -euo pipefail
# Build a standalone 32-bit json-glib DLL against the Pidgin 2 Win32 SDK.
: "${JSON_GLIB_VERSION:=1.10.8}"
: "${OUT_DIR:=$PWD/dist/json-glib-win32}"
: "${WIN32_DEV_TOP:=$PWD/win32-dev}"
: "${JSON_GLIB_SOURCE:=$PWD/json-glib-src}"
: "${GLIB_SDK_DIR:=$WIN32_DEV_TOP/glib-2.28.8}"
test -d "$GLIB_SDK_DIR/include" || { echo "Missing Win32 GLib SDK" >&2; exit 1; }
command -v i686-w64-mingw32-gcc
command -v meson
command -v ninja
# json-glib 1.10 needs newer GLib than the historical 2.28 SDK.
# Fail explicitly rather than publish a DLL with an unverified ABI.
echo "Win32 json-glib build requires a compatible GLib SDK and version-pinned source." >&2
echo "The bundled Pidgin GLib 2.28.8 SDK is too old for json-glib $JSON_GLIB_VERSION." >&2
exit 2
