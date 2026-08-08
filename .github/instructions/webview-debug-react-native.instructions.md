---
description: "Use when implementing, debugging, or testing the React Native WebView debugger app in apps/WebViewDebugRN. Covers WebViewConfig and AsyncStorage persistence, typed React Navigation, react-native-webview props and messages, platform debug settings, and Jest validation."
name: "WebView Debug React Native App Conventions"
applyTo: "apps/WebViewDebugRN/**"
---

# WebView Debug React Native App Conventions

- Apply these conventions only to the React Native app in `apps/WebViewDebugRN`.
- Keep the entry and typed navigation flow as `App -> ConfigScreen -> PreviewScreen({config})` through `RootStackParamList`.
- Keep configuration centralized in the `WebViewConfig` interface and `DEFAULT_CONFIG`; update state immutably with functional `setConfig` and object spread.
- When adding, renaming, or removing a config field, update the interface, default, persisted JSON compatibility, ConfigScreen control, Preview route handoff, react-native-webview prop or runtime behavior, and tests as applicable.
- Keep the persisted config contract stable in AsyncStorage key `@webview_config` as JSON.
- Preserve backward compatibility with stored JSON by validating parsed values and merging missing fields with `DEFAULT_CONFIG`. Do not change the storage key or reinterpret an existing field without an explicit migration requirement.
- Preserve URL validation before navigation: only allow `http://` or `https://`, and keep invalid input on ConfigScreen with an actionable alert.
- Keep asynchronous storage failures and component lifetime in mind; avoid navigation or state updates after an obsolete async operation.
- Keep PreviewScreen behavior driven by the typed route config through explicit `react-native-webview` props.
- Keep WebView navigation state synchronized from `onNavigationStateChange`, including `canGoBack` and `canGoForward`, and keep loading state synchronized across load and error callbacks.
- For JavaScript communication, use `window.ReactNativeWebView.postMessage` and a single guarded `onMessage` dispatcher with a versionable JSON envelope. Validate message shape, type, and payload before side effects.
- Keep external URL handling explicit through React Native `Linking`; keep same-WebView navigation on the WebView ref or source state.
- Keep `webviewDebuggingEnabled` driven by `debuggingEnabled`, and keep Android-only debug UI guarded with `Platform.OS === 'android'`.
- Preserve current debug-first platform settings unless explicitly asked otherwise: Android cleartext/debuggable support and iOS App Transport Security and permissions must remain aligned with WebView debugging behavior.
- Do not edit generated Android/iOS output, Pods, `node_modules`, Metro caches, or build directories.
- Add deterministic Jest tests for config defaults and migration, AsyncStorage loading and saving, URL validation, typed navigation handoff, message parsing, and affected UI behavior. Mock native modules and WebView rather than using a real network or device WebView.
- From `apps/WebViewDebugRN`, run `npm run lint`, `npx tsc --noEmit`, and the focused or full `npm test -- --runInBand` command before completing a change.
