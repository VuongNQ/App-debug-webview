---
name: "WebView Config Tests"
description: "Create or extend deterministic Flutter tests for WebViewConfig defaults and JSON, SharedPreferences persistence, URL validation, and the ConfigScreen-to-PreviewScreen handoff."
argument-hint: "Config behavior or regression that needs test coverage"
agent: "Flutter WebView Maintainer"
---

# Test WebView Configuration Behavior

Use the user's arguments to identify the config behavior or regression to cover. Inspect [WebViewConfig and ConfigScreen](../../apps/webview-debug-flutter/lib/screens/config_screen.dart), [PreviewScreen](../../apps/webview-debug-flutter/lib/screens/preview_screen.dart), and the existing [widget tests](../../apps/webview-debug-flutter/test/widget_test.dart).

Create focused tests for the requested behavior, choosing from:

- `WebViewConfig` defaults, `copyWith`, `toJson`, and `fromJson` round trips.
- Backward compatibility when stored JSON omits newer fields.
- Config loading and saving through the `webview_config` SharedPreferences key.
- Typed, clipboard, and QR URL validation for `http://` and `https://`.
- The `ConfigScreen` handoff to `PreviewScreen` when it can be tested without a live platform WebView.

Use `SharedPreferences.setMockInitialValues` before pumping the app. Keep tests deterministic, reset shared state between cases, use descriptive test names, and avoid real network access, camera input, or native WebView initialization when a model or widget boundary can verify the contract.

Run formatting checks, `flutter analyze`, and the narrowest relevant `flutter test` command from `apps/webview-debug-flutter`. Report coverage added, validation results, and any behavior that remains platform-only.
