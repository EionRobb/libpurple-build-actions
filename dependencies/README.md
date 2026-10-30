# Optional json-glib dependency bundles (work in progress)

json-glib is an optional **plugin dependency**, not a prerequisite for every libpurple plugin.

The intended release deliverables are:
- macOS: `libjson-glib-1.0.a` for x86_64 and arm64, target headers, and build manifest.
- Win32: `json-glib-1.0.dll`, its import library, and headers for i686 MinGW.

Build these separately from plugin CI, then publish checksum-verified, versioned release assets. Plugin builds should consume a pinned bundle rather than rebuilding the GLib dependency graph.

**Compatibility:** A static json-glib archive still needs ABI-compatible GLib/GObject at runtime. Do not statically link a second GLib copy into a plugin. Windows DLL builds must use the GLib ABI expected by the target Pidgin installation. MacOS dynamic_lookup alone does not ensure json-glib is available to the host.

The initial osxcross experiment in purple-googlechat PR #115 did not complete: GLib's `libcharset.a` was not in Mach-O format. Do not publish or consume a macOS archive until the cross-build and a real macOS load test succeed.

The Win32 SDK currently includes GLib 2.28.8; build the Windows DLL against those development files rather than reusing a binary from the Facebook plugin. Keep this dependency optional in setup-win32.
