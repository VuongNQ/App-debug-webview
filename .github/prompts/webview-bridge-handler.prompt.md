---
name: "WebView Bridge Handler"
description: "Add or debug one JavaScript bridge handler in the Flutter InAppWebView preview, including argument validation, navigation routing, tests, and Flutter validation."
argument-hint: "Handler name and expected JavaScript-to-Flutter behavior"
agent: "Flutter WebView Maintainer"
---

# Implement One WebView Bridge Handler

Use the user's arguments as the handler name and expected JavaScript-to-Flutter behavior.

Inspect [PreviewScreen](../../apps/webview-debug-flutter/lib/screens/preview_screen.dart), its callers, and relevant tests. Add or debug only the requested handler in `onWebViewCreated` unless a small supporting change is required.

Requirements:

- Guard argument count and runtime types before reading values.
- Define the callback's return value when JavaScript depends on it.
- Check `mounted` before context, navigation, or UI work after an `await`.
- Route external applications through `url_launcher` and same-WebView navigation through `loadUrl`.
- Preserve existing handler names and behavior unless the request explicitly changes them.
- Keep platform-specific behavior explicit and avoid changing debug-first platform settings incidentally.
- Add the narrowest deterministic test possible. Do not require a real network or platform WebView when the behavior can be isolated.

Run formatting checks, `flutter analyze`, and the focused Flutter test from `apps/webview-debug-flutter`. Finish with the changed handler contract, files changed, validation results, and any platform-only verification still required.
