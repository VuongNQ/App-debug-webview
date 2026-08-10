---
description: "Use when implementing, debugging, or testing the Flutter WebView debugger app in apps/webview-debug-flutter. Covers WebViewConfig persistence, config-to-preview settings, JavaScript bridge handlers, navigation, network panel, platform settings, and Flutter validation."
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

## Network DevTools Panel

- The network panel lives in lib/screens/network_panel.dart and its data model in lib/models/network_entry.dart. Do not inline network capture logic elsewhere.
- NetworkEntry is an immutable value object. Extend it with copyWith; never mutate fields directly.
- NetworkEntryType has nine values: xhr, fetch, document, stylesheet, script, image, media, socket, other. Map new resource sub-types here rather than adding a broad catch-all.
- Use _resourceTypeFromInitiator(String?) in PreviewScreen to map LoadedResource.initiatorType to the correct NetworkEntryType. Extend that switch when new initiator types are needed.
- Network capture in PreviewScreen uses three hooks: shouldInterceptAjaxRequest (XHR, both platforms), onAjaxReadyStateChange (XHR response, update entry via copyWith when readyState == DONE), and shouldInterceptFetchRequest (Fetch, Android only). Always return the original request object from intercept callbacks to avoid blocking requests.
- useShouldInterceptAjaxRequest and useShouldInterceptFetchRequest are set to true unconditionally in InAppWebViewSettings because they serve the debug panel, not the page config.
- useOnLoadResource follows widget.config.useOnLoadResource; resource entries appear only when the user enables it in config.
- The network log is a ValueNotifier<List<NetworkEntry>>. Add entries by replacing the list value (spread + append) rather than mutating the existing list. Match XHR responses by lastIndexWhere on url + type + null statusCode.
- Attach a listener on the ValueNotifier in initState to call setState for badge count updates. Dispose the notifier in dispose.
- NetworkPanel is a StatefulWidget. Its only local state is the active NetworkFilter. All list reactivity comes from ValueListenableBuilder over the shared notifier.
- NetworkFilter has seven values: all, xhrFetch, doc, css, js, image, socket. Filtering is applied inside the builder; the badge count reflects the filtered length.
- _DetailDialog is a StatefulWidget shown via showDialog. It has no local state after the Raw/Preview toggle was removed. If no state remains, prefer converting it to a StatelessWidget.
- The cURL builder (_buildCurl) escapes single quotes in the body with the POSIX '\'' idiom. Keep it side-effect-free and static.
- Copy actions use Clipboard.setData followed by a mounted check before showing the ScaffoldMessenger snackbar.
- Copy as cURL and Copy Response actions are shown only for xhr/fetch entries; Copy Response additionally requires responseBodyPreview != null.
- Response body is shown as raw selectable text via _DetailSection. Do not re-introduce a Raw/Preview toggle without an explicit request.
- The network FAB button uses Badge (Material 3) with isLabelVisible driven by the log length. heroTag must be unique: 'webview-network-action'.
- The panel is opened via showModalBottomSheet with isScrollControlled: true and useSafeArea: true. Pass logNotifier and an onClear callback that sets the notifier value to [].
