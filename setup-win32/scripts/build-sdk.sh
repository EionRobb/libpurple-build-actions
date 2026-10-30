#!/usr/bin/env bash
set -euo pipefail
: "${PIDGIN_VERSION:=2.14.1}"
if [[ ! "$PIDGIN_VERSION" =~ ^2\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid Pidgin version" >&2
  exit 1
fi
if [[ -e pidgin || -e win32-dev ]]; then
  echo "Expected clean SDK directories (pidgin and win32-dev)" >&2
  exit 1
fi

download_dir="$(mktemp -d)"
curl -fL --retry 3 --http1.1 "https://sourceforge.net/projects/pidgin/files/Pidgin/${PIDGIN_VERSION}/pidgin-${PIDGIN_VERSION}.tar.bz2/download" -o "$download_dir/pidgin.tar.bz2"
tar -xf "$download_dir/pidgin.tar.bz2"
mv "pidgin-${PIDGIN_VERSION}" pidgin
curl -fL --retry 3 --http1.1 "https://sourceforge.net/projects/pidgin/files/Pidgin/${PIDGIN_VERSION}/pidgin-${PIDGIN_VERSION}-win32-bin.zip/download" -o "$download_dir/win32-bin.zip"
unzip -q "$download_dir/win32-bin.zip" -d "$download_dir/win32-bin"
libpurple_dll="$(find "$download_dir/win32-bin" -name libpurple.dll -type f -print -quit)"
test -n "$libpurple_dll"
cp "$libpurple_dll" pidgin/libpurple/

mkdir -p win32-dev/glib-2.28.8
curl -fL --retry 3 https://download.gnome.org/binaries/win32/glib/2.28/glib-dev_2.28.8-1_win32.zip -o "$download_dir/glib.zip"
unzip -q "$download_dir/glib.zip" -d win32-dev/glib-2.28.8
curl -fL --retry 3 https://download.gnome.org/binaries/win32/dependencies/gettext-runtime-dev_0.18.1.1-2_win32.zip -o "$download_dir/gettext.zip"
unzip -q "$download_dir/gettext.zip" -d win32-dev/glib-2.28.8
curl -fL --retry 3 https://download.gnome.org/binaries/win32/dependencies/zlib-dev_1.2.5-2_win32.zip -o "$download_dir/zlib.zip"
unzip -q "$download_dir/zlib.zip" -d win32-dev/glib-2.28.8

test -f pidgin/libpurple/libpurple.dll
test -d win32-dev/glib-2.28.8/include
