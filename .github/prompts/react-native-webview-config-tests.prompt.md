---
name: "React Native WebView Config Tests"
description: "Create or extend deterministic Jest tests for React Native WebViewConfig defaults and migration, AsyncStorage persistence, URL validation, typed navigation, WebView props, and UI behavior."
argument-hint: "Config, persistence, navigation, or WebView regression that needs test coverage"
agent: "React Native WebView Maintainer"
---

# Test React Native WebView Configuration

Use the user's arguments to identify the config behavior or regression to cover. Inspect [ConfigScreen](../../apps/WebViewDebugRN/src/screens/ConfigScreen.tsx), [navigation types](../../apps/WebViewDebugRN/src/types.ts), [PreviewScreen](../../apps/WebViewDebugRN/src/screens/PreviewScreen.tsx), and the existing [App test](../../apps/WebViewDebugRN/__tests__/App.test.tsx).

Create focused tests for the requested behavior, choosing from:

- `DEFAULT_CONFIG`, immutable state updates, allowed union values, and migration of missing or invalid persisted fields.
- AsyncStorage loading and saving through the `@webview_config` key, including malformed JSON and rejected operations.
- `http://` and `https://` URL validation and the invalid-URL alert.
- Typed `Config -> Preview({config})` navigation and route handoff.
- Mapping route config to `react-native-webview` props, navigation history controls, loading state, error alerts, and Android-only debug UI.
- Guarded parsing and dispatch of WebView messages when message behavior is in scope.

Reset mocks between tests. Mock AsyncStorage, React Navigation, `react-native-webview`, `Linking`, `Alert`, and `Platform` only as needed. Assert observable behavior rather than implementation details, and do not use real network access or native WebView initialization.

From `apps/WebViewDebugRN`, run `npm run lint`, `npx tsc --noEmit`, and the narrowest relevant Jest command with `--runInBand`. Report coverage added, validation results, and any behavior that remains device-only.
