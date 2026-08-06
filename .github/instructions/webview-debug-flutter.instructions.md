---
description: "Use when working on the Flutter WebView debugger app in apps/webview-debug-flutter. Covers app structure, config-to-preview workflow, persisted state contract, WebView bridge behavior, and debug-first platform settings."
name: "WebView Debug Flutter App Conventions"
applyTo: "apps/webview-debug-flutter/**"
---

# WebView Debug Flutter App Conventions

- Apply these conventions only to the Flutter app in apps/webview-debug-flutter.
- Prefer keeping entry and navigation flow as main -> ConfigScreen -> PreviewScreen(config).
- Prefer keeping state shape centralized in WebViewConfig and update it with copyWith rather than ad-hoc mutable maps.
- Keep the persisted config contract stable in SharedPreferences key webview_config as JSON via toJson and fromJson.
- Preserve URL validation in ConfigScreen before opening preview: only allow http:// or https://.
- Keep async UI safety checks after awaits by verifying mounted before navigation or UI side effects.
- In PreviewScreen, keep WebView behavior driven from WebViewConfig through InAppWebViewSettings.
- Keep JavaScript bridge handlers registered in onWebViewCreated and guard handler args before reading values.
- Keep external links routed through url_launcher and internal links through WebView loadUrl.
- Keep navigation UI state updates synchronized from onLoadStart and onLoadStop for loading, currentUrl, canGoBack, and canGoForward.
- Keep Android remote inspection behavior tied to debuggingEnabled and Android platform checks.
- Prefer preserving current debug-first platform settings unless explicitly asked otherwise.
- Keep AndroidManifest cleartext and debuggable settings aligned with the app's WebView debugging workflow.
- Keep iOS App Transport Security and permission keys aligned with the app's development WebView debugging workflow.
- When changing behavior, update tests in apps/webview-debug-flutter/test to cover config loading, URL validation, and persistence compatibility.