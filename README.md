# libpurple build actions

Public, MIT-licensed **environment setup** actions for libpurple 2.x plugins. These actions stop before compilation: each plugin owns its build, optional dependencies, packaging, artifacts, and releases.

> Initial release is experimental. No downstream plugin workflows have been changed or validated yet. Pin to a commit SHA until a tested v1 release is available.

## Actions

### `setup-linux` (Ubuntu 24.04 x86_64 / arm64)

Downloads Ubuntu's libpurple development/runtime packages and **extracts**, rather than forcibly installs, them. This avoids leaving APT with unsatisfied dependencies. Installs basic GLib development tools; plugins install their own other dependencies.

```yaml
- uses: actions/checkout@v4
- uses: EionRobb/libpurple-build-actions/setup-linux@main
- run: sudo apt-get install -y libjson-glib-dev libprotobuf-c-dev
- run: make
```

Exports `LIBPURPLE_SDK_ROOT`, `PKG_CONFIG_PATH`, `LIBRARY_PATH`, `LD_LIBRARY_PATH` and `CPATH` for following steps. It is intended for **building**, not running Pidgin. Package versions depend on the pinned runner image. Other Ubuntu versions are not yet supported.

### `setup-win32` (Ubuntu runner, 32-bit Windows cross-compile)

Installs the MinGW i686 C compiler and supplies Pidgin source, libpurple.dll, GLib, gettext and zlib development files. Uses a repository-local Actions cache and tries a centrally published Win32 SDK release asset; if unavailable, assembles the files from upstream downloads. No protobuf, NSS, QRencode, rlottie, wixl or C++ compiler is installed.

```yaml
- uses: actions/checkout@v4
- uses: EionRobb/libpurple-build-actions/setup-win32@main
  with:
    pidgin-version: '2.14.1'
- run: sudo apt-get install -y protobuf-c-compiler
- run: make libmyplugin.dll
```

Exports `WIN32_CC=i686-w64-mingw32-gcc`, `PIDGIN_TREE_TOP=pidgin`, and `WIN32_DEV_TOP=win32-dev`. Supported target versions initially include 2.14.1 and legacy 2.10.11, with upstream fallback if a matching release archive has not been published.

### `setup-osxcross` (Ubuntu runner, macOS cross-compile)

Builds a pinned osxcross compiler with an Apple SDK supplied by the calling workflow. Uses the caller repository's Actions cache. **This repository does not redistribute Apple SDK binaries.**

```yaml
- uses: actions/checkout@v4
- uses: EionRobb/libpurple-build-actions/setup-osxcross@main
  with:
    sdk-url: ${{ vars.MACOS_SDK_URL }}
    sdk-sha256: ${{ vars.MACOS_SDK_SHA256 }}
- run: echo "Toolchain: $OSXCROSS/bin; target: $DARWIN_TARGET"
```

The SDK URL and checksum are required. This action prepares a compiler, *not* target-platform GLib/libpurple development libraries. Native macOS builds are deliberately out of scope.

## SDK release process

Run **Build Win32 SDK release** with `workflow_dispatch`. It creates an SDK archive and SHA-256 checksum, then publishes them to a versioned release tag. Downstream builds attempt a checksum-verified download, using a per-repository Actions cache to avoid repeated extraction.

Release assets contain third-party upstream development libraries and binaries; their original licensing remains applicable. The MIT licence here covers this project's own code, not the third-party SDK contents.

## Design principles

- Setup only; never call `make` or release plugin artifacts.
- Optional protocol dependencies are installed by downstream plugins as additional steps.
- Keep package management usable after setup: never use `dpkg --force-depends`.
- Verify downloaded release archives with published checksums.
- Treat build environments as versioned inputs; avoid silent changes to toolchains.

See the individual action metadata for inputs and output environment variables.

## Licence

MIT; see [LICENSE](LICENSE).
