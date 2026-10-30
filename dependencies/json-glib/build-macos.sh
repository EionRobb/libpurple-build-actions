#!/usr/bin/env bash
set -euo pipefail
# Cross-compile a reusable json-glib static archive per Darwin architecture.
# Requires a compatible target GLib SDK prepared separately.
: "${JSON_GLIB_VERSION:=1.10.8}"
: "${OSXCROSS:=/opt/osxcross}"
: "${DARWIN_TARGET:?Set DARWIN_TARGET from setup-osxcross}"
: "${MACOS_GLIB_SDK:?Set MACOS_GLIB_SDK to a macOS target GLib development sysroot}"
: "${OUT_DIR:=$PWD/dist}"
command -v meson
command -v ninja
test -d "$MACOS_GLIB_SDK"
if [[ ! -d json-glib-src ]]; then
  git clone --depth 1 --branch "$JSON_GLIB_VERSION" https://gitlab.gnome.org/GNOME/json-glib.git json-glib-src
fi
for arch in x86_64 arm64; do
  triplet="$arch-apple-$DARWIN_TARGET"
  prefix="$OUT_DIR/$arch"
  mkdir -p "$prefix"
  cat > "json-glib-$arch.cross" <<EOF
[binaries]
c = '$OSXCROSS/bin/$triplet-clang'
cpp = '$OSXCROSS/bin/$triplet-clang++'
ar = '$OSXCROSS/bin/$triplet-ar'
strip = '$OSXCROSS/bin/$triplet-strip'
pkg-config = '/usr/bin/pkg-config'
[properties]
pkg_config_libdir = '$MACOS_GLIB_SDK/$arch/lib/pkgconfig'
[host_machine]
system = 'darwin'
cpu_family = '$([ "$arch" = arm64 ] && echo aarch64 || echo x86_64)'
cpu = '$arch'
endian = 'little'
EOF
  PKG_CONFIG_LIBDIR="$MACOS_GLIB_SDK/$arch/lib/pkgconfig" \
    meson setup "json-glib-build-$arch" json-glib-src \
      --cross-file "json-glib-$arch.cross" --prefix="$prefix" \
      --default-library=static -Dintrospection=disabled -Dtests=false \
      -Ddocumentation=disabled -Dnls=disabled
  meson compile -C "json-glib-build-$arch"
  meson install -C "json-glib-build-$arch"
  test -s "$prefix/lib/libjson-glib-1.0.a"
done
