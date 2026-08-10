---
name: flutter-webview-config-change
description: "Use when adding, renaming, removing, migrating, or debugging a Flutter WebViewConfig option across ConfigScreen, SharedPreferences JSON, PreviewScreen InAppWebViewSettings, Android or iOS settings, and tests. Do NOT use for network panel changes (NetworkEntry, NetworkFilter, NetworkPanel, capture hooks in PreviewScreen) — apply the Network DevTools Panel rules in the instructions file instead."
argument-hint: "Describe the WebView config option and its expected default and platform behavior"
user-invocable: true
disable-model-invocation: false
---

# Flutter WebView Config Change

Evolve one WebView configuration option end-to-end without breaking stored configurations or leaving the config UI and preview behavior out of sync.

Follow [WebView Debug Flutter App Conventions](../../instructions/webview-debug-flutter.instructions.md) throughout this workflow.

## Procedure

1. Establish the contract.
   - Locate the current field, constructor default, UI control, persistence representation, and `InAppWebViewSettings` mapping.
   - State the expected default, supported platforms, persisted JSON shape, and behavior for existing users before editing.
   - Check the installed `flutter_inappwebview` API rather than guessing a setting name or platform capability.

2. Update `WebViewConfig` completely.
   - Keep the field immutable.
   - Update the declaration, constructor and default, `copyWith` parameter and assignment, `toJson`, and `fromJson`.
   - Give missing JSON fields a backward-compatible default.
   - For a rename, continue reading the old JSON key when compatibility is required and write only the canonical key.

3. Wire `ConfigScreen`.
   - Add or update the control in the appropriate basic or advanced settings section.
   - Use `copyWith` for state changes.
   - For text-backed options, synchronize the controller during initialization and persisted config loading, include its value when opening the preview, and dispose it.
   - Preserve `http://` and `https://` validation for URL sources and check `mounted` after asynchronous gaps.

4. Wire `PreviewScreen`.
   - Map the config value to the correct `InAppWebViewSettings` property or the smallest explicit runtime behavior.
   - Preserve Android-only and iOS-only conditions rather than pretending a setting is cross-platform.
   - Keep bridge, internal navigation, external launch, loading, and history behavior unchanged unless the option directly affects them.

5. Assess platform configuration.
   - Inspect AndroidManifest permissions, cleartext/debuggable settings, Gradle constraints, iOS Info.plist permissions, and App Transport Security only when the option depends on them.
   - Preserve the app's debug-first behavior and avoid dependency or toolchain upgrades unless required.

6. Add compatibility-focused tests.
   - Cover the default value, `copyWith`, JSON round trip, and deserialization when the field is absent.
   - Add a widget test for the control or handoff when the behavior is visible before native WebView initialization.
   - Initialize SharedPreferences mocks explicitly and avoid real network, camera, or platform WebView dependencies where possible.

7. Validate from `apps/webview-debug-flutter`.
   - Format touched Dart files with `dart format`.
   - Run `dart format --output=none --set-exit-if-changed lib test`.
   - Run `flutter analyze`.
   - Run the focused test, then the full `flutter test` suite when shared config or persistence behavior changed.
   - Report any Android or iOS behavior that still requires device verification.

## Stop And Clarify

Stop before editing and ask for the intended compatibility policy when:

- The `webview_config` storage key must change.
- Existing stored values need an incompatible type or semantic change.
- Removing an option could change behavior for existing stored configurations.
- The requested `flutter_inappwebview` setting has unclear or different Android and iOS semantics.
- The change requires a dependency, Gradle, Kotlin, Flutter, CocoaPods, or deployment-target upgrade.

## Completion Report

Summarize the config contract, all synchronized layers, migration behavior, tests run, validation results, and remaining device-only checks.
