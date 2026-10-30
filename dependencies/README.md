# Optional json-glib dependency (Windows)

The Pidgin 2 Windows plugins purple-teams, purple-discord and purple-googlechat use the historical `json-glib-0.14` headers and import library with the `glib-2.28.8` SDK.

This repository builds its own **32-bit Windows DLL** from GNOME json-glib **0.14.2** source rather than copying the binary supplied by an unrelated plugin. The upstream 0.14 series requires GLib >= 2.26.

Run the **Build legacy Win32 json-glib DLL** workflow to build and inspect a development artifact. The workflow also runs for PR changes to this dependency.

**Current limitations:** this is not yet a tested or published release. Verify the source archive checksum, DLL imports, plugin loading against older Windows Pidgin runtimes, and runtime dependencies before distributing it. Build output is explicitly marked unverified. The existing setup-win32 action and SDK release are unchanged.

**macOS:** Keep json-glib dynamically resolved as in purple-googlechat PR #115. No macOS static json-glib archive is planned: embedding duplicate json-glib implementations across plugins introduces avoidable symbol-interposition risk.
