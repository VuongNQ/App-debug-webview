---
description: "Use when implementing, debugging, or testing the Flutter WebView debugger app in apps/webview-debug-flutter. Covers WebViewConfig persistence, config-to-preview settings, JavaScript bridge handlers, navigation, platform settings, and Flutter validation."
name: "WebView Debug Flutter App Conventions"
applyTo: "apps/webview-debug-flutter/**"
---

# WebView Debug Flutter App Conventions

- Apply these conventions only to the Flutter app in apps/webview-debug-flutter.
- Prefer keeping entry and navigation flow as main -> ConfigScreen -> PreviewScreen(config).
- Prefer keeping state shape centralized in WebViewConfig and update it with copyWith rather than ad-hoc mutable maps.
- When adding, renaming, or removing a WebViewConfig field, update its declaration, constructor default, copyWith parameter and assignment, toJson, fromJson fallback, ConfigScreen control or controller, PreviewScreen InAppWebViewSettings mapping, and compatibility tests as applicable.
- Keep the persisted config contract stable in SharedPreferences key webview_config as JSON via toJson and fromJson.
- Preserve backward compatibility with stored JSON by providing defaults for missing fields. Do not change the storage key or reinterpret an existing field without an explicit migration requirement.
- Preserve URL validation in ConfigScreen before opening preview: only allow http:// or https://.
- Apply the same URL scheme validation to typed, pasted, and QR-scanned values, with source-specific error messages.
- Keep async UI safety checks after awaits by verifying mounted before setState, navigation, or UI side effects.
- In PreviewScreen, keep WebView behavior driven from WebViewConfig through InAppWebViewSettings.
- Keep JavaScript bridge handlers registered in onWebViewCreated, guard handler args and types before reading values, and preserve safe async context usage.
- Keep external links routed through url_launcher and internal links through WebView loadUrl.
- Keep navigation UI state updates synchronized from onLoadStart and onLoadStop for loading, currentUrl, canGoBack, and canGoForward.
- Keep Android remote inspection behavior tied to debuggingEnabled and Android platform checks.
- Prefer preserving current debug-first platform settings unless explicitly asked otherwise.
- Keep AndroidManifest cleartext and debuggable settings aligned with the app's WebView debugging workflow.
- Keep iOS App Transport Security and permission keys aligned with the app's development WebView debugging workflow.
- For Windows Android builds, preserve the Kotlin in-process, non-incremental, non-parallel Gradle settings unless a verified tooling change makes them unnecessary.
- When changing behavior, update tests in apps/webview-debug-flutter/test to cover defaults, config loading, URL validation, persistence compatibility, and the affected UI flow without relying on a real network or platform WebView when avoidable.
- Run dart format --output=none --set-exit-if-changed lib test, flutter analyze, and the focused or full flutter test command from apps/webview-debug-flutter before completing a change.
