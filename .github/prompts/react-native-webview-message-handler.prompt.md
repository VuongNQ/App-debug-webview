---
name: "React Native WebView Message Handler"
description: "Add or debug one postMessage and onMessage contract in the React Native WebView preview, including JSON validation, guarded side effects, Jest tests, and TypeScript validation."
argument-hint: "Message type, payload shape, sender, and expected React Native behavior"
agent: "React Native WebView Maintainer"
---

# Implement One React Native WebView Message Handler

Use the user's arguments as the message type, payload contract, sender, and expected native behavior.

Inspect [PreviewScreen](../../apps/WebViewDebugRN/src/screens/PreviewScreen.tsx), its route contract, and relevant tests. Add or debug only the requested message in a single `onMessage` dispatcher unless a small supporting change is required.

Requirements:

- Use `window.ReactNativeWebView.postMessage` for WebView-to-React-Native communication.
- Prefer a JSON envelope such as `{version, type, payload}` over ad-hoc strings.
- Treat `nativeEvent.data` as untrusted input: catch JSON parsing errors and validate the envelope, message type, and payload before side effects.
- Ignore or report unsupported message types without crashing the preview.
- Keep navigation typed through `RootStackParamList` and avoid stale state or navigation work after obsolete asynchronous operations.
- Open external applications with React Native `Linking`; keep same-WebView navigation on the WebView ref or controlled source.
- Preserve existing WebView props, history state, loading state, and platform debug behavior unless the requested message explicitly affects them.
- Add the narrowest deterministic Jest test using mocked WebView and native modules rather than a real network or device WebView.

From `apps/WebViewDebugRN`, run `npm run lint`, `npx tsc --noEmit`, and the focused Jest test with `--runInBand`. Finish with the message envelope, accepted payload, side effects, files changed, validation results, and any device-only verification still required.
