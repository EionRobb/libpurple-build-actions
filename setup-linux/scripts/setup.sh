#!/usr/bin/env bash
set -euo pipefail

source /etc/os-release
if [[ "${ID}" != "ubuntu" || "${VERSION_ID}" != "24.04" ]]; then
  echo "::error::setup-linux initially supports Ubuntu 24.04 only" >&2
  exit 1
fi

sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends libglib2.0-dev pkg-config

sdk_root="${RUNNER_TEMP}/libpurple-sdk"
mkdir -p "$sdk_root"
download_dir="$(mktemp -d)"
cd "$download_dir"
apt download libpurple0t64 libpurple-dev
for deb in ./*.deb; do
  dpkg-deb -x "$deb" "$sdk_root"
done

# Debian .pc files assume /usr. Point them at the extracted SDK instead.
while IFS= read -r -d '' pc; do
  sed -i "s|^prefix=/usr$|prefix=${sdk_root}/usr|" "$pc"
done < <(find "$sdk_root/usr" -name '*.pc' -print0)

arch="$(dpkg-architecture -qDEB_HOST_MULTIARCH)"
sdk_lib="${sdk_root}/usr/lib/${arch}"
sdk_pc="${sdk_lib}/pkgconfig"
for var in LIBPURPLE_SDK_ROOT PKG_CONFIG_PATH LIBRARY_PATH LD_LIBRARY_PATH CPATH; do
  case "$var" in
    LIBPURPLE_SDK_ROOT) value="$sdk_root" ;;
    PKG_CONFIG_PATH) value="${sdk_pc}:${sdk_root}/usr/lib/pkgconfig:${PKG_CONFIG_PATH:-}" ;;
    LIBRARY_PATH) value="${sdk_lib}:${sdk_root}/usr/lib:${LIBRARY_PATH:-}" ;;
    LD_LIBRARY_PATH) value="${sdk_lib}:${sdk_root}/usr/lib:${LD_LIBRARY_PATH:-}" ;;
    CPATH) value="${sdk_root}/usr/include:${sdk_root}/usr/include/libpurple:${CPATH:-}" ;;
  esac
  echo "$var=$value" >> "$GITHUB_ENV"
  export "$var=$value"
done

pkg-config --exists purple || {
  echo "::error::Extracted libpurple pkg-config metadata could not be resolved" >&2
  exit 1
}
echo "libpurple development metadata: $(pkg-config --modversion purple)"
