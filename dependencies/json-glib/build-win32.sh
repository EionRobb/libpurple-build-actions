#!/usr/bin/env bash
set -euo pipefail
# Build json-glib 0.14.2 for Pidgin 2's historical GLib 2.28.x runtime.
: "${JSON_GLIB_VERSION:=0.14.2}"
: "${WIN32_DEV_TOP:=$PWD/win32-dev}"
: "${OUT_DIR:=$PWD/dist/json-glib-win32}"
: "${GLIB_SDK_DIR:=$WIN32_DEV_TOP/glib-2.28.8}"
: "${HOST:=i686-w64-mingw32}"
test "$JSON_GLIB_VERSION" = 0.14.2 || { echo "Only pinned json-glib 0.14.2 is supported" >&2; exit 1; }
test -d "$GLIB_SDK_DIR/include" || { echo "Missing GLib SDK: $GLIB_SDK_DIR" >&2; exit 1; }
for tool in curl tar make "${HOST}-gcc" "${HOST}-ar" "${HOST}-ranlib"; do command -v "$tool"; done
mkdir -p "$OUT_DIR"
OUT_DIR="$(realpath "$OUT_DIR")"
GLIB_SDK_DIR="$(realpath "$GLIB_SDK_DIR")"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
url="https://download.gnome.org/sources/json-glib/0.14/json-glib-0.14.2.tar.xz"
curl -fL --retry 3 "$url" -o "$work/json-glib.tar.xz"
# Upstream publishes checksums; verify against upstream before production release.
tar -xJf "$work/json-glib.tar.xz" -C "$work"
cd "$work/json-glib-0.14.2"
# This is an Autotools-era release, not Meson.
export CC="${HOST}-gcc" AR="${HOST}-ar" RANLIB="${HOST}-ranlib"
export CPPFLAGS="-I$GLIB_SDK_DIR/include -I$GLIB_SDK_DIR/include/glib-2.0 -I$GLIB_SDK_DIR/lib/glib-2.0/include"
export LDFLAGS="-L$GLIB_SDK_DIR/lib"
export PKG_CONFIG_LIBDIR="$GLIB_SDK_DIR/lib/pkgconfig"
export PKG_CONFIG_PATH=""
./configure --host="$HOST" --prefix="$OUT_DIR" --disable-static --enable-shared --disable-gtk-doc --disable-introspection --disable-nls
make -j2
make install
test -s "$OUT_DIR/bin/libjson-glib-1.0-0.dll" || test -s "$OUT_DIR/bin/libjson-glib-1.0.dll"
find "$OUT_DIR" -type f \( -name '*json-glib*.dll' -o -name '*json-glib*.dll.a' \) -print
