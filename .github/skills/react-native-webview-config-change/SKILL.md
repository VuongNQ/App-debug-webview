---
name: react-native-webview-config-change
description: "Use when adding, renaming, removing, migrating, or debugging a React Native WebViewConfig option across DEFAULT_CONFIG, ConfigScreen, AsyncStorage JSON, typed navigation, PreviewScreen WebView props, Android or iOS settings, and Jest tests."
argument-hint: "Describe the WebView config option and its expected default, persisted shape, and platform behavior"
user-invocable: true
disable-model-invocation: false
---

# React Native WebView Config Change

Evolve one React Native WebView configuration option end-to-end without breaking stored configurations or leaving ConfigScreen, navigation, and PreviewScreen out of sync.

Follow [WebView Debug React Native App Conventions](../../instructions/webview-debug-react-native.instructions.md) throughout this workflow.

## Procedure

1. Establish the contract.

   - Locate the current `WebViewConfig` field, `DEFAULT_CONFIG` value, state control, persisted JSON representation, typed route handoff, and WebView prop or runtime mapping.
   - State the expected TypeScript type, default, supported platforms, stored JSON shape, and behavior for existing users before editing.
   - Check the installed `react-native-webview` types or documentation rather than guessing a prop name or platform capability.

2. Update the config model and migration path.

   - Update `WebViewConfig` and `DEFAULT_CONFIG` together.
   - Keep config updates immutable with the functional `setConfig(current => ({...current, field: value}))` pattern.
   - Validate parsed AsyncStorage data and merge missing fields with `DEFAULT_CONFIG` so older JSON remains usable.
   - For a rename, read the old JSON key when compatibility is required, normalize it to the canonical field, and persist only the canonical shape on the next save.
   - Reject or normalize invalid persisted union values and primitive types instead of trusting `JSON.parse` output.

3. Wire ConfigScreen.

   - Add or update the control in the appropriate settings section using existing TextInput, Switch, or option-control patterns.
   - Keep the control typed and driven by `config` state.
   - Preserve `http://` and `https://` URL validation and actionable alerts.
   - Handle AsyncStorage failures deliberately and avoid state or navigation work after an obsolete asynchronous operation.

4. Preserve typed navigation.

   - Keep `RootStackParamList` as the route source of truth.
   - Pass the complete normalized config through `navigation.navigate('Preview', {config})`.
   - Avoid `any`, unchecked casts, duplicate route types, or untyped access to `route.params`.

5. Wire PreviewScreen.

   - Map the config value to the correct `react-native-webview` prop or the smallest explicit runtime behavior.
   - Preserve Android-only and iOS-only conditions rather than treating platform-specific props as universal.
   - Keep history, loading, error, message, and debug-banner behavior unchanged unless the option directly affects them.
   - If the option changes WebView messaging, extend the single guarded `onMessage` dispatcher and its versioned message contract.

6. Assess platform configuration.

   - Inspect AndroidManifest permissions, cleartext and debuggable settings, Gradle configuration, iOS Info.plist permissions, and App Transport Security only when the option depends on them.
   - Preserve the app's debug-first behavior and avoid dependency or toolchain upgrades unless required.

7. Add compatibility-focused Jest tests.

   - Cover the default value, immutable update behavior, stored JSON with the field present, and migration when the field is absent or invalid.
   - Cover the ConfigScreen control, AsyncStorage save, typed navigation handoff, or PreviewScreen prop mapping when observable at those boundaries.
   - Reset mocks between tests and mock AsyncStorage, React Navigation, WebView, Platform, Alert, or Linking only as needed.
   - Avoid real network access and native WebView initialization.

8. Validate from `apps/WebViewDebugRN`.
   - Run the repository formatter on touched TypeScript files when formatting changes are needed.
   - Run `npm run lint`.
   - Run `npx tsc --noEmit`.
   - Run the focused Jest test with `--runInBand`, then the full `npm test -- --runInBand` suite when shared config, persistence, or navigation behavior changed.
   - Report any Android or iOS behavior that still requires device verification.

## Stop And Clarify

Stop before editing and ask for the intended compatibility policy when:

- The `@webview_config` AsyncStorage key must change.
- Existing stored values need an incompatible type or semantic change.
- Removing an option could change behavior for existing stored configurations.
- The requested WebView prop has unclear or different Android and iOS semantics.
- The change requires a React Native, React, react-native-webview, React Navigation, Gradle, Kotlin, CocoaPods, or deployment-target upgrade.

## Completion Report

Summarize the config contract, synchronized layers, persisted-data migration, tests run, lint and typecheck results, and remaining device-only checks.
